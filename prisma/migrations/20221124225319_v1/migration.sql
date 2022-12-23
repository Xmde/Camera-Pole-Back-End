-- CreateEnum
CREATE TYPE "EventType" AS ENUM ('Vehicle', 'Motion');

-- CreateEnum
CREATE TYPE "Facing" AS ENUM ('North', 'South', 'East', 'West');

-- CreateEnum
CREATE TYPE "Direction" AS ENUM ('Forward', 'Backward', 'None');

-- CreateEnum
CREATE TYPE "ObjectType" AS ENUM ('People', 'Bicycle', 'Vehicle', 'Unknown');

-- CreateTable
CREATE TABLE "VehicleType" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "VehicleType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Plate" (
    "id" SERIAL NOT NULL,
    "plate" TEXT,
    "nickname" TEXT,
    "identifier" TEXT NOT NULL,
    "vehicle_type_id" INTEGER NOT NULL,

    CONSTRAINT "Plate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Camera" (
    "id" SERIAL NOT NULL,
    "camera_number" INTEGER NOT NULL,
    "facing" "Facing" NOT NULL DEFAULT 'North',

    CONSTRAINT "Camera_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Event" (
    "id" SERIAL NOT NULL,
    "plate_id" INTEGER,
    "object_type" "ObjectType" NOT NULL DEFAULT 'Unknown',
    "camera_id" INTEGER NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "image" TEXT NOT NULL,
    "direction" "Direction" NOT NULL DEFAULT 'None',

    CONSTRAINT "Event_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Plate" ADD CONSTRAINT "Plate_vehicle_type_id_fkey" FOREIGN KEY ("vehicle_type_id") REFERENCES "VehicleType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_plate_id_fkey" FOREIGN KEY ("plate_id") REFERENCES "Plate"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_camera_id_fkey" FOREIGN KEY ("camera_id") REFERENCES "Camera"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
