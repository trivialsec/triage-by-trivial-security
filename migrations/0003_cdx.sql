-- CreateTable
CREATE TABLE "cdx" (
    "cdxId" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "memberEmail" TEXT NOT NULL,
    "repoName" TEXT,
    "cdxVersion" TEXT NOT NULL,
    "serialNumber" TEXT,
    "name" TEXT,
    "version" TEXT,
    "createdAt" INTEGER NOT NULL,
    "toolName" TEXT,
    "externalReferencesJSON" TEXT,
    "componentsJSON" TEXT,
    "dependenciesJSON" TEXT,
    CONSTRAINT "cdx_memberEmail_fkey" FOREIGN KEY ("memberEmail") REFERENCES "members" ("email") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "cdx_repoName_fkey" FOREIGN KEY ("repoName") REFERENCES "git_repos" ("fullName") ON DELETE
    SET NULL ON UPDATE CASCADE
);
-- RedefineTables
PRAGMA defer_foreign_keys = ON;
PRAGMA foreign_keys = OFF;
CREATE TABLE "new_findings" (
    "findingId" TEXT NOT NULL,
    "memberEmail" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "createdAt" INTEGER NOT NULL,
    "modifiedAt" INTEGER NOT NULL,
    "publishedAt" INTEGER,
    "detectionTitle" TEXT NOT NULL,
    "purl" TEXT,
    "cpe" TEXT,
    "databaseReviewed" INTEGER,
    "cve" TEXT,
    "aliases" TEXT,
    "cwes" TEXT,
    "packageName" TEXT NOT NULL,
    "packageVersion" TEXT,
    "packageLicense" TEXT,
    "vendor" TEXT,
    "product" TEXT,
    "packageEcosystem" TEXT,
    "sourceCodeUrl" TEXT,
    "exploitsJSON" TEXT,
    "knownExploitsJSON" TEXT,
    "cisaDateAdded" INTEGER,
    "knownRansomwareCampaignUse" TEXT,
    "fixVersion" TEXT,
    "fixAutomatable" INTEGER,
    "vulnerableVersionRange" TEXT,
    "maliciousSource" TEXT,
    "abandoned" INTEGER,
    "squattedPackage" TEXT,
    "referencesJSON" TEXT,
    "spdxId" TEXT,
    "cdxId" TEXT
);
INSERT INTO "new_findings" (
        "abandoned",
        "aliases",
        "category",
        "cdxId",
        "cisaDateAdded",
        "cpe",
        "createdAt",
        "cve",
        "cwes",
        "databaseReviewed",
        "detectionTitle",
        "exploitsJSON",
        "findingId",
        "fixAutomatable",
        "fixVersion",
        "knownExploitsJSON",
        "knownRansomwareCampaignUse",
        "maliciousSource",
        "memberEmail",
        "modifiedAt",
        "packageEcosystem",
        "packageLicense",
        "packageName",
        "packageVersion",
        "product",
        "publishedAt",
        "purl",
        "referencesJSON",
        "source",
        "sourceCodeUrl",
        "spdxId",
        "squattedPackage",
        "vendor",
        "vulnerableVersionRange"
    )
SELECT "abandoned",
    "aliases",
    "category",
    "cdxId",
    "cisaDateAdded",
    "cpe",
    "createdAt",
    "cve",
    "cwes",
    "databaseReviewed",
    "detectionTitle",
    "exploitsJSON",
    "findingId",
    "fixAutomatable",
    "fixVersion",
    "knownExploitsJSON",
    "knownRansomwareCampaignUse",
    "maliciousSource",
    "memberEmail",
    "modifiedAt",
    "packageEcosystem",
    "packageLicense",
    "packageName",
    "packageVersion",
    "product",
    "publishedAt",
    "purl",
    "referencesJSON",
    "source",
    "sourceCodeUrl",
    "spdxId",
    "squattedPackage",
    "vendor",
    "vulnerableVersionRange"
FROM "findings";
DROP TABLE "findings";
ALTER TABLE "new_findings"
    RENAME TO "findings";
-- CreateIndex
CREATE UNIQUE INDEX "findings_findingId_key" ON "findings"("findingId");
CREATE UNIQUE INDEX "cdx_cdxId_key" ON "cdx"("cdxId");
