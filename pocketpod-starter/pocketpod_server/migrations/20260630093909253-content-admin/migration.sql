BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "post" (
    "id" INTEGER PRIMARY KEY,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "published" INTEGER NOT NULL,
    "publishedAt" INTEGER,
    "authorId" INTEGER NOT NULL,
    "updatedAt" INTEGER NOT NULL
) STRICT;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product" (
    "id" INTEGER PRIMARY KEY,
    "sku" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "price" REAL NOT NULL,
    "stock" INTEGER NOT NULL,
    "published" INTEGER NOT NULL,
    "categoryId" INTEGER NOT NULL,
    "updatedAt" INTEGER NOT NULL
) STRICT;

--
-- STORE COLUMN TYPES FOR MIGRATIONS
--
DROP TABLE IF EXISTS "serverpod_sqlite_schema";

CREATE TABLE "serverpod_sqlite_schema" (
    "table_name" TEXT NOT NULL,
    "column_name" TEXT NOT NULL,
    "column_type" TEXT NOT NULL,
    "column_vector_dimension" INTEGER,
    PRIMARY KEY ("table_name", "column_name")
);

INSERT INTO "serverpod_sqlite_schema" VALUES
    ('benchmark_record', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('post', 'published', 'boolean', NULL),
    ('post', 'publishedAt', 'timestampWithoutTimeZone', NULL),
    ('post', 'updatedAt', 'timestampWithoutTimeZone', NULL),
    ('product', 'published', 'boolean', NULL),
    ('product', 'updatedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage', 'addedTime', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage', 'expiration', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage', 'verified', 'boolean', NULL),
    ('serverpod_cloud_storage_direct_upload', 'expiration', 'timestampWithoutTimeZone', NULL),
    ('serverpod_future_call', 'time', 'timestampWithoutTimeZone', NULL),
    ('serverpod_future_call', 'scheduling', 'json', NULL),
    ('serverpod_future_call_claim', 'lastHeartbeatTime', 'timestampWithoutTimeZone', NULL),
    ('serverpod_health_connection_info', 'timestamp', 'timestampWithoutTimeZone', NULL),
    ('serverpod_health_metric', 'timestamp', 'timestampWithoutTimeZone', NULL),
    ('serverpod_health_metric', 'isHealthy', 'boolean', NULL),
    ('serverpod_log', 'time', 'timestampWithoutTimeZone', NULL),
    ('serverpod_message_log', 'slow', 'boolean', NULL),
    ('serverpod_migrations', 'timestamp', 'timestampWithoutTimeZone', NULL),
    ('serverpod_query_log', 'slow', 'boolean', NULL),
    ('serverpod_runtime_settings', 'logSettings', 'json', NULL),
    ('serverpod_runtime_settings', 'logSettingsOverrides', 'json', NULL),
    ('serverpod_runtime_settings', 'logServiceCalls', 'boolean', NULL),
    ('serverpod_runtime_settings', 'logMalformedCalls', 'boolean', NULL),
    ('serverpod_session_log', 'time', 'timestampWithoutTimeZone', NULL),
    ('serverpod_session_log', 'slow', 'boolean', NULL),
    ('serverpod_session_log', 'isOpen', 'boolean', NULL),
    ('serverpod_session_log', 'touched', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_anonymous_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_anonymous_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_anonymous_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_apple_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_apple_account', 'refreshTokenRequestedWithBundleIdentifier', 'boolean', NULL),
    ('serverpod_auth_idp_apple_account', 'lastRefreshedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_apple_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_apple_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_apple_account', 'isEmailVerified', 'boolean', NULL),
    ('serverpod_auth_idp_apple_account', 'isPrivateEmail', 'boolean', NULL),
    ('serverpod_auth_idp_email_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_email_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'emailAccountId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'challengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'setPasswordChallengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_request', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_request', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_email_account_request', 'challengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_request', 'createAccountChallengeId', 'uuid', NULL),
    ('serverpod_auth_idp_facebook_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_facebook_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_facebook_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_firebase_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_firebase_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_firebase_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_github_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_github_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_github_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_google_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_google_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_google_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_microsoft_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_microsoft_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_microsoft_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_passkey_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_passkey_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_passkey_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_passkey_challenge', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_passkey_challenge', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_rate_limited_request_attempt', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_rate_limited_request_attempt', 'attemptedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_rate_limited_request_attempt', 'extraData', 'json', NULL),
    ('serverpod_auth_idp_secret_challenge', 'id', 'uuid', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'id', 'uuid', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'scopeNames', 'json', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'lastUpdatedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_profile', 'id', 'uuid', NULL),
    ('serverpod_auth_core_profile', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_core_profile', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_profile', 'imageId', 'uuid', NULL),
    ('serverpod_auth_core_profile_image', 'id', 'uuid', NULL),
    ('serverpod_auth_core_profile_image', 'userProfileId', 'uuid', NULL),
    ('serverpod_auth_core_profile_image', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_session', 'id', 'uuid', NULL),
    ('serverpod_auth_core_session', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_core_session', 'scopeNames', 'json', NULL),
    ('serverpod_auth_core_session', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_session', 'lastUsedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_session', 'expiresAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_user', 'id', 'uuid', NULL),
    ('serverpod_auth_core_user', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_user', 'scopeNames', 'json', NULL),
    ('serverpod_auth_core_user', 'blocked', 'boolean', NULL);

--
-- MIGRATION VERSION FOR pocketpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pocketpod', '20260630093909253-content-admin', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260630093909253-content-admin', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260416151914983-insights-perf', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416151914983-insights-perf', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260417182309198', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182309198', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260417182253191', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182253191', "timestamp" = (unixepoch('now', 'subsecond') * 1000);


COMMIT;
