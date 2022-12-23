import { Direction, PrismaClient } from "@prisma/client";
import dotenv from "dotenv";
import FtpServer from "ftp-srv";
import path from "path";
import moment from "moment-timezone";
import express from "express";
import glob from "glob";

dotenv.config();

const ftp_port = process.env.FTP_PORT || 3000;
const express_port = process.env.EXPRESS_PORT || 3001;
const ip = process.env.SERVER_IP || "10.1.80.102";
const uname = process.env.SERVER_USERNAME || "user";
const pass = process.env.FTP_PASS || "defaultPassword";
const folder_path = process.env.FOLDER_PATH || "/mnt/lpr";

const ftpServer = new FtpServer({
  url: "ftp://0.0.0.0:" + ftp_port,
  pasv_url: ip,
  pasv_min: 50000,
  pasv_max: 60000,
});

const prisma = new PrismaClient();

const app = express();
app.use(express.static(folder_path));

ftpServer.on(
  "login",
  ({ connection, username, password }: any, resolve: any, reject: any) => {
    connection.on("STOR", (err: any, filePath: string) => {
      if (err) return console.error(err);
      filePath = filePath.split(path.sep).join(path.posix.sep);
      handleNewEvent(filePath.slice(filePath.indexOf("/")));
    });

    if (username === uname && password === pass) {
      return resolve({ root: folder_path });
    }
    return reject(new Error("Invalid username or password"));
  }
);

ftpServer.listen().then(() => {
  console.log(`Ftp server is starting Port: ${ftp_port}, IP: ${ip}`);
});

async function handleNewEvent(filePath: string) {
  // Checks to make sure file is in correct directory;
  if (!validateFile(filePath)) return;
  const cameraNumber = Number(filePath.split("/")[3]);
  if (isNaN(cameraNumber)) return;

  if (filePath.includes("MOTION_DETECTION")) {
    return await handleMotionEvent(filePath, cameraNumber);
  }
  await handlePlateEvent(filePath, cameraNumber);
}

async function handleMotionEvent(filePath: string, cameraNumber: number) {
  const timestampString = filePath.split("_")[2];
  const timestamp = dateFromString(timestampString);
  if (!timestamp.isValid()) return;
  const DBcamera = await prisma.camera.upsert({
    where: {
      camera_number: cameraNumber,
    },
    update: {},
    create: {
      camera_number: cameraNumber,
      facing: cameraNumber % 2 === 0 ? "North" : "South",
    },
  });
  await prisma.event.upsert({
    where: {
      id: processEventId(filePath),
    },
    update: {},
    create: {
      id: processEventId(filePath),
      camera_id: DBcamera.id,
      timestamp: timestamp.toDate(),
      image: `http://${ip}:${express_port}${filePath.slice(
        folder_path.length
      )}`,
      event_type: "Motion",
    },
  });
}

async function handlePlateEvent(filePath: string, cameraNumber: number) {
  const timestampString = filePath.split("_")[1];
  const timestamp = dateFromString(timestampString);
  if (!timestamp.isValid()) return;
  const DBcamera = await prisma.camera.upsert({
    where: {
      camera_number: cameraNumber,
    },
    update: {},
    create: {
      camera_number: cameraNumber,
      facing: cameraNumber % 2 === 0 ? "North" : "South",
    },
  });

  const plateRaw = filePath.split("_")[2];
  const plateNumber = convertPlate(plateRaw);
  const rawDirection = filePath
    .split("/")
    [filePath.split("/").length - 1].split("_")[0];
  // console.log(
  //   filePath.split("/")[filePath.split("/").length - 1].split("_")[0]
  // );
  let direction: Direction;
  if (rawDirection === "FORWARD") {
    direction = "Forward";
  } else if (rawDirection === "REVERSE") {
    direction = "Backward";
  } else {
    direction = "Unknown";
  }

  const DBPublic = await prisma.vehicleType.upsert({
    where: {
      name: "Public",
    },
    update: {},
    create: {
      name: "Public",
    },
  });

  if (plateNumber == "unknown") {
    await prisma.event.upsert({
      where: {
        id: processEventId(filePath),
      },
      update: {},
      create: {
        id: processEventId(filePath),
        camera_id: DBcamera.id,
        timestamp: timestamp.toDate(),
        image: `http://${ip}:${express_port}${filePath.slice(
          folder_path.length
        )}`,
        event_type: "Vehicle",
        object_type: "Vehicle",
        direction: direction,
      },
    });
  } else {
    const DBplate = await prisma.plate.upsert({
      where: {
        id: plateNumber,
      },
      update: {},
      create: {
        id: plateNumber,
        plate: plateRaw,
        vehicle_type_id: DBPublic.id,
      },
    });
    await prisma.event.upsert({
      where: {
        id: processEventId(filePath),
      },
      update: {},
      create: {
        id: processEventId(filePath),
        camera_id: DBcamera.id,
        timestamp: timestamp.toDate(),
        image: `http://${ip}:${express_port}${filePath.slice(
          folder_path.length
        )}`,
        plate_id: DBplate.id,
        event_type: "Vehicle",
        object_type: "Vehicle",
        direction: direction,
      },
    });
  }
}

function dateFromString(dateString: string) {
  return moment.utc(dateString.slice(0, -3), "YYYYMMDDHHmmss").add(8, "hours");
}

/**
 * Checks to make sure file has the correct path structure
 * Valid path structure:/folder_path/{cameraNumber}/{Direction}_{TimeStamp}_{PlateNumber}_PLATE.jpg
 * Valid path structure:/folder_path/{cameraNumber}/192.168.1.11_01_{TimeStamp}_MOTION_DETECTION.jpg
 *
 * @param filePath filepath to check
 */
function validateFile(filePath: string) {
  if (!filePath.endsWith(".jpg")) return false;
  if (!filePath.startsWith(folder_path)) return;

  const pathParts = filePath.split("/");
  if (pathParts.length !== 5) return false;
  if (
    pathParts[4].split("_").length !== 4 &&
    pathParts[4].split("_").length !== 5
  )
    return false;

  if (filePath.endsWith("MOTION_DETECTION.jpg")) return true;
  if (filePath.endsWith("BACKGROUND.jpg")) return true;
  return false;
}

app.listen(express_port, () => {
  console.log(`Express server is listening on port ${express_port}`);
});

function convertPlate(plate: string) {
  if (plate === "unknown") return plate;
  const dict = {
    A: "A",
    B: "B",
    C: "C",
    D: "B",
    E: "E",
    F: "E",
    G: "G",
    H: "H",
    I: "I",
    J: "I",
    K: "K",
    L: "I",
    M: "M",
    N: "M",
    O: "B",
    P: "K",
    Q: "B",
    R: "K",
    S: "S",
    T: "T",
    U: "U",
    V: "U",
    W: "W",
    X: "U",
    Y: "U",
    Z: "Z",
    "0": "B",
    "1": "I",
    "2": "Z",
    "3": "3",
    "4": "4",
    "5": "S",
    "6": "G",
    "7": "T",
    "8": "B",
    "9": "9",
  };
  let output = "";
  for (let i = 0; i < plate.length; i++) {
    if (String(dict[plate[i] as keyof typeof dict]) !== "undefined") {
      output += String(dict[plate[i] as keyof typeof dict]);
    }
  }
  return output;
}

function processEventId(eventId: string) {
  return eventId
    .replace(/[^a-z0-9_]+/gi, "-")
    .replace(/^-|-$/g, "")
    .toLowerCase();
}

function main() {
  glob("**/*.jpg", { cwd: folder_path }, async (err, files) => {
    if (err) {
      console.error(err);
      return;
    }
    console.log(`Handling Files: ${files.length} files to process`);
    for (const file of files) {
      const fullFilePath = path.join(folder_path, file);
      const filePath = fullFilePath.split(path.sep).join(path.posix.sep);
      await handleNewEvent(filePath.slice(filePath.indexOf("/")));
    }
    console.log("Finished Handling Files");
  });
}

main();
