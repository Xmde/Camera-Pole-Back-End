/*
  Warnings:

  - The values [None] on the enum `Direction` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "Direction_new" AS ENUM ('Forward', 'Backward', 'Unknown');
ALTER TABLE "Event" ALTER COLUMN "direction" DROP DEFAULT;
ALTER TABLE "Event" ALTER COLUMN "direction" TYPE "Direction_new" USING ("direction"::text::"Direction_new");
ALTER TYPE "Direction" RENAME TO "Direction_old";
ALTER TYPE "Direction_new" RENAME TO "Direction";
DROP TYPE "Direction_old";
ALTER TABLE "Event" ALTER COLUMN "direction" SET DEFAULT 'Unknown';
COMMIT;

-- AlterTable
ALTER TABLE "Event" ALTER COLUMN "direction" SET DEFAULT 'Unknown';
