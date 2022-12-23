/*
  Warnings:

  - Made the column `plate` on table `Plate` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "Plate" ALTER COLUMN "plate" SET NOT NULL;
