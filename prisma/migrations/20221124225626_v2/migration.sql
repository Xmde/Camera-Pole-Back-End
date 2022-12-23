/*
  Warnings:

  - A unique constraint covering the columns `[camera_number]` on the table `Camera` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Camera_camera_number_key" ON "Camera"("camera_number");
