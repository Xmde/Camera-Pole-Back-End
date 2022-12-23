/*
  Warnings:

  - A unique constraint covering the columns `[plate]` on the table `Plate` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[identifier]` on the table `Plate` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Plate_plate_key" ON "Plate"("plate");

-- CreateIndex
CREATE UNIQUE INDEX "Plate_identifier_key" ON "Plate"("identifier");
