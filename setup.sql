-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "role" TEXT,
    "status" TEXT,
    "password_hash" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "members" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "gender" TEXT,
    "department" TEXT,
    "role" TEXT,
    "status" TEXT,
    "date_joined" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "departments" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "description" TEXT,
    "leader" TEXT,
    "members_count" INTEGER,
    "status" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "committees" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "description" TEXT,
    "status" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "committees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "groups" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "description" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "description" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "description" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "group_roles" (
    "id" UUID NOT NULL,
    "group_id" TEXT NOT NULL,
    "role_id" TEXT NOT NULL,

    CONSTRAINT "group_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "id" UUID NOT NULL,
    "role_id" TEXT NOT NULL,
    "permission_id" TEXT NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_groups" (
    "id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,
    "group_id" TEXT NOT NULL,

    CONSTRAINT "user_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "department_members" (
    "id" UUID NOT NULL,
    "department_id" TEXT NOT NULL,
    "member_id" TEXT NOT NULL,
    "role" TEXT,

    CONSTRAINT "department_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "committee_members" (
    "id" UUID NOT NULL,
    "committee_id" TEXT NOT NULL,
    "member_id" TEXT NOT NULL,
    "role" TEXT,

    CONSTRAINT "committee_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "activities" (
    "id" UUID NOT NULL,
    "action" TEXT,
    "details" TEXT,
    "time" TEXT,
    "type" TEXT,

    CONSTRAINT "activities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sms_records" (
    "id" UUID NOT NULL,
    "message" TEXT,
    "recipients" TEXT,
    "recipient_count" INTEGER,
    "date" TEXT,
    "status" TEXT,
    "recipient_type" TEXT,
    "provider_status" TEXT,
    "provider_code" TEXT,
    "provider_message" TEXT,
    "provider_response" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "sms_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "latency_logs" (
    "id" UUID NOT NULL,
    "source" TEXT,
    "method" TEXT,
    "path" TEXT,
    "status" INTEGER,
    "duration_ms" INTEGER,
    "timestamp" TEXT,

    CONSTRAINT "latency_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branches" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "location" TEXT,
    "address" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "status" TEXT,
    "created_by" TEXT,
    "created_at" TEXT,
    "last_edited_by" TEXT,
    "last_edited_at" TEXT,
    "sent_by" TEXT,

    CONSTRAINT "branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_pastors" (
    "id" UUID NOT NULL,
    "branch_id" TEXT NOT NULL,
    "member_id" TEXT NOT NULL,
    "role" TEXT,

    CONSTRAINT "branch_pastors_pkey" PRIMARY KEY ("id")
);

