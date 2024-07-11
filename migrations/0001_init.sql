-- CreateTable
CREATE TABLE "sessions" (
    "kid" TEXT NOT NULL,
    "memberEmail" TEXT NOT NULL,
    "expiry" INTEGER NOT NULL,
    "issued" INTEGER NOT NULL,
    "secret" TEXT,
    "authn_ip" TEXT,
    "authn_ua" TEXT
);
-- CreateTable
CREATE TABLE "members" (
    "email" TEXT NOT NULL PRIMARY KEY,
    "orgName" TEXT,
    "passwordHash" TEXT NOT NULL,
    "avatarUrl" TEXT,
    "firstName" TEXT,
    "lastName" TEXT,
    "alertNews" INTEGER NOT NULL DEFAULT 0,
    "alertOverdue" INTEGER NOT NULL DEFAULT 0,
    "alertFindings" INTEGER NOT NULL DEFAULT 0,
    "alertType" INTEGER NOT NULL DEFAULT 0
);
-- CreateTable
CREATE TABLE "member_keys" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "memberEmail" TEXT NOT NULL,
    "keyLabel" TEXT,
    "keyType" TEXT NOT NULL,
    "secret" TEXT NOT NULL,
    "suspend" INTEGER NOT NULL DEFAULT 0
);
-- CreateTable
CREATE TABLE "github_apps" (
    "installationId" TEXT NOT NULL,
    "memberEmail" TEXT NOT NULL,
    "accessToken" TEXT NOT NULL,
    "login" TEXT,
    "created" INTEGER NOT NULL,
    "expires" INTEGER
);
-- CreateTable
CREATE TABLE "git_repos" (
    "pk" TEXT NOT NULL,
    "fullName" TEXT NOT NULL PRIMARY KEY,
    "createdAt" INTEGER NOT NULL,
    "updatedAt" INTEGER NOT NULL,
    "pushedAt" INTEGER NOT NULL,
    "defaultBranch" TEXT NOT NULL,
    "ownerId" INTEGER NOT NULL,
    "memberEmail" TEXT NOT NULL,
    "licenseSpdxId" TEXT,
    "licenseName" TEXT,
    "fork" INTEGER NOT NULL DEFAULT 0,
    "template" INTEGER NOT NULL DEFAULT 0,
    "archived" INTEGER NOT NULL DEFAULT 0,
    "visibility" TEXT NOT NULL,
    "avatarUrl" TEXT
);
-- CreateTable
CREATE TABLE "sarif" (
    "sarifId" TEXT NOT NULL,
    "reportId" TEXT NOT NULL PRIMARY KEY,
    "fullName" TEXT,
    "source" TEXT NOT NULL,
    "memberEmail" TEXT NOT NULL,
    "commitSha" TEXT,
    "ref" TEXT,
    "createdAt" INTEGER NOT NULL,
    "resultsCount" INTEGER NOT NULL,
    "rulesCount" INTEGER NOT NULL,
    "toolName" TEXT,
    "toolVersion" TEXT,
    "analysisKey" TEXT,
    "warning" TEXT
);
-- CreateTable
CREATE TABLE "sarif_results" (
    "guid" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "messageText" TEXT NOT NULL,
    "ruleId" TEXT NOT NULL,
    "locations" TEXT,
    "automationDetailsId" TEXT,
    "rulesetName" TEXT,
    "level" TEXT,
    "description" TEXT,
    "helpMarkdown" TEXT,
    "securitySeverity" TEXT,
    "precision" TEXT,
    "tags" TEXT
);
-- CreateTable
CREATE TABLE "spdx" (
    "spdxId" TEXT NOT NULL,
    "spdxVersion" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "repoName" TEXT,
    "name" TEXT,
    "dataLicense" TEXT,
    "documentNamespace" TEXT,
    "toolName" TEXT,
    "packageCount" INTEGER NOT NULL,
    "createdAt" INTEGER NOT NULL,
    "memberEmail" TEXT NOT NULL,
    "comment" TEXT
);
-- CreateTable
CREATE TABLE "integration_usage_log" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "memberEmail" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "request" TEXT NOT NULL,
    "response" TEXT,
    "statusCode" INTEGER NOT NULL,
    "createdAt" INTEGER NOT NULL
);
-- CreateTable
CREATE TABLE "findings" (
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
    "licenseDeclared" TEXT,
    "maliciousSource" TEXT,
    "abandoned" INTEGER,
    "squattedPackage" TEXT,
    "referencesJSON" TEXT,
    "spdxId" TEXT,
    "cdxId" TEXT
);
-- CreateTable
CREATE TABLE "triage_activity" (
    "findingId" TEXT NOT NULL PRIMARY KEY,
    "createdAt" INTEGER NOT NULL,
    "lastObserved" INTEGER NOT NULL,
    "seen" INTEGER NOT NULL,
    "seenAt" INTEGER,
    "cvssVector" TEXT,
    "cvssScore" TEXT,
    "epssPercentile" TEXT,
    "epssScore" TEXT,
    "ssvc" TEXT,
    "remediation" TEXT,
    "analysisState" TEXT NOT NULL,
    "analysisJustification" TEXT,
    "analysisResponseJSON" TEXT,
    "analysisDetail" TEXT
);
-- CreateIndex
CREATE UNIQUE INDEX "sessions_kid_key" ON "sessions"("kid");
-- CreateIndex
CREATE UNIQUE INDEX "members_email_key" ON "members"("email");
-- CreateIndex
CREATE UNIQUE INDEX "member_keys_memberEmail_secret_key" ON "member_keys"("memberEmail", "secret");
-- CreateIndex
CREATE UNIQUE INDEX "github_apps_installationId_key" ON "github_apps"("installationId");
-- CreateIndex
CREATE UNIQUE INDEX "git_repos_pk_key" ON "git_repos"("pk");
-- CreateIndex
CREATE UNIQUE INDEX "sarif_sarifId_key" ON "sarif"("sarifId");
-- CreateIndex
CREATE UNIQUE INDEX "sarif_results_guid_key" ON "sarif_results"("guid");
-- CreateIndex
CREATE UNIQUE INDEX "spdx_spdxId_key" ON "spdx"("spdxId");
-- CreateIndex
CREATE UNIQUE INDEX "findings_findingId_key" ON "findings"("findingId");
-- CreateIndex
CREATE UNIQUE INDEX "triage_activity_findingId_analysisState_key" ON "triage_activity"("findingId", "analysisState");
