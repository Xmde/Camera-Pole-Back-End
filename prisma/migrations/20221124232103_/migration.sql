/*
  Warnings:

  - A unique constraint covering the columns `[name]` on the table `VehicleType` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "VehicleType_name_key" ON "VehicleType"("name");
