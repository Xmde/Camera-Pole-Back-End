/*
  Warnings:

  - The primary key for the `Camera` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `Event` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `Plate` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `identifier` on the `Plate` table. All the data in the column will be lost.
  - You are about to drop the column `nickname` on the `Plate` table. All the data in the column will be lost.
  - The primary key for the `VehicleType` table will be changed. If it partially fails, the table could be left without primary key constraint.

*/
-- DropForeignKey
ALTER TABLE "Event" DROP CONSTRAINT "Event_camera_id_fkey";

-- DropForeignKey
ALTER TABLE "Event" DROP CONSTRAINT "Event_plate_id_fkey";

-- DropForeignKey
ALTER TABLE "Plate" DROP CONSTRAINT "Plate_vehicle_type_id_fkey";

-- DropIndex
DROP INDEX "Plate_identifier_key";

-- AlterTable
ALTER TABLE "Camera" DROP CONSTRAINT "Camera_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "Camera_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "Camera_id_seq";

-- AlterTable
ALTER TABLE "Event" DROP CONSTRAINT "Event_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "plate_id" SET DATA TYPE TEXT,
ALTER COLUMN "camera_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "Event_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "Event_id_seq";

-- AlterTable
ALTER TABLE "Plate" DROP CONSTRAINT "Plate_pkey",
DROP COLUMN "identifier",
DROP COLUMN "nickname",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "vehicle_type_id" SET DATA TYPE TEXT,
ADD CONSTRAINT "Plate_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "Plate_id_seq";

-- AlterTable
ALTER TABLE "VehicleType" DROP CONSTRAINT "VehicleType_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "VehicleType_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "VehicleType_id_seq";

-- AddForeignKey
ALTER TABLE "Plate" ADD CONSTRAINT "Plate_vehicle_type_id_fkey" FOREIGN KEY ("vehicle_type_id") REFERENCES "VehicleType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_plate_id_fkey" FOREIGN KEY ("plate_id") REFERENCES "Plate"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_camera_id_fkey" FOREIGN KEY ("camera_id") REFERENCES "Camera"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
