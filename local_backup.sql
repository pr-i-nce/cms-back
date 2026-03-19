--
-- PostgreSQL database dump
--


-- Dumped from database version 14.22 (Ubuntu 14.22-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.22 (Ubuntu 14.22-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.activities (
    id character varying(255) NOT NULL,
    action character varying(255),
    details character varying(255),
    "time" character varying(255),
    type character varying(255)
);


ALTER TABLE public.activities OWNER TO penielch_u53r;

--
-- Name: branch_pastors; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.branch_pastors (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    branch_id text NOT NULL,
    member_id text NOT NULL,
    role text
);


ALTER TABLE public.branch_pastors OWNER TO penielch_u53r;

--
-- Name: branches; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.branches (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    name text,
    location text,
    address text,
    phone text,
    email text,
    status text,
    created_by text,
    created_at text,
    last_edited_by text,
    last_edited_at text,
    sent_by text
);


ALTER TABLE public.branches OWNER TO penielch_u53r;

--
-- Name: committee_members; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.committee_members (
    id character varying(255) NOT NULL,
    committee_id character varying(255),
    member_id character varying(255),
    role character varying(255)
);


ALTER TABLE public.committee_members OWNER TO penielch_u53r;

--
-- Name: committees; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.committees (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    description character varying(255),
    name character varying(255),
    status character varying(255)
);


ALTER TABLE public.committees OWNER TO penielch_u53r;

--
-- Name: department_members; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.department_members (
    id character varying(255) NOT NULL,
    department_id character varying(255),
    member_id character varying(255),
    role character varying(255)
);


ALTER TABLE public.department_members OWNER TO penielch_u53r;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.departments (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    description character varying(255),
    leader character varying(255),
    members_count integer,
    name character varying(255),
    status character varying(255)
);


ALTER TABLE public.departments OWNER TO penielch_u53r;

--
-- Name: group_roles; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.group_roles (
    id character varying(255) NOT NULL,
    group_id character varying(255),
    role_id character varying(255)
);


ALTER TABLE public.group_roles OWNER TO penielch_u53r;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.groups (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    description character varying(255),
    name character varying(255)
);


ALTER TABLE public.groups OWNER TO penielch_u53r;

--
-- Name: latency_logs; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.latency_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source text,
    method text,
    path text,
    status integer,
    duration_ms integer,
    "timestamp" text
);


ALTER TABLE public.latency_logs OWNER TO penielch_u53r;

--
-- Name: members; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.members (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    date_joined character varying(255),
    department character varying(255),
    email character varying(255),
    gender character varying(255),
    name character varying(255),
    phone character varying(255),
    role character varying(255),
    status character varying(255)
);


ALTER TABLE public.members OWNER TO penielch_u53r;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.permissions (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    description character varying(255),
    name character varying(255)
);


ALTER TABLE public.permissions OWNER TO penielch_u53r;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.refresh_tokens (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    user_id text NOT NULL,
    token_hash text NOT NULL,
    created_at text,
    expires_at text,
    revoked_at text,
    replaced_by text,
    last_used_at text
);


ALTER TABLE public.refresh_tokens OWNER TO penielch_u53r;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.role_permissions (
    id character varying(255) NOT NULL,
    permission_id character varying(255),
    role_id character varying(255)
);


ALTER TABLE public.role_permissions OWNER TO penielch_u53r;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.roles (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    description character varying(255),
    name character varying(255)
);


ALTER TABLE public.roles OWNER TO penielch_u53r;

--
-- Name: sms_records; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.sms_records (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    date character varying(255),
    message character varying(255),
    recipient_count integer,
    recipient_type character varying(255),
    recipients character varying(255),
    status character varying(255),
    provider_code character varying(255),
    provider_message character varying(255),
    provider_response text,
    provider_status character varying(255)
);


ALTER TABLE public.sms_records OWNER TO penielch_u53r;

--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.user_groups (
    id character varying(255) NOT NULL,
    group_id character varying(255),
    user_id character varying(255)
);


ALTER TABLE public.user_groups OWNER TO penielch_u53r;

--
-- Name: users; Type: TABLE; Schema: public; Owner: peniel
--

CREATE TABLE public.users (
    id character varying(255) NOT NULL,
    created_at character varying(255),
    created_by character varying(255),
    last_edited_at character varying(255),
    last_edited_by character varying(255),
    sent_by character varying(255),
    email character varying(255),
    name character varying(255),
    password_hash character varying(255),
    role character varying(255),
    status character varying(255),
    phone character varying(255)
);


ALTER TABLE public.users OWNER TO penielch_u53r;

--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.activities (id, action, details, "time", type) FROM stdin;
be98f779-7afc-420b-9054-0456bc1315db	LOGIN	FAIL email=superadmin@church.local reason=INVALID_CREDENTIALS ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T08:49:20.249Z	auth
583db655-a72d-4ed6-9e87-a2ef218d48f7	LOGIN	FAIL email=superadmin@church.local reason=INVALID_CREDENTIALS ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T08:49:23.607Z	auth
f73f5557-3206-493a-ac45-3271382f36d9	LOGIN	FAIL email=superadmin@church.local reason=INVALID_CREDENTIALS ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T08:50:27.519Z	auth
df3431d2-78bf-429e-9c46-2d133a27286a	LOGIN	FAIL email=admin@church.local reason=INVALID_CREDENTIALS ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T08:57:14.788Z	auth
597cb003-c8f8-4051-b875-15eeaf077cfd	LOGIN	FAIL email=admin@church.local reason=INVALID_CREDENTIALS ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T08:57:29.949Z	auth
0fd05a5a-845c-4f20-9845-c203e379114a	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T08:57:40.105Z	auth
4002c60c-587a-406d-8333-0b71d625f92e	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T09:36:07.867Z	auth
2adaf623-aefb-4c56-8561-4ffc5dd97d85	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T09:44:31.154Z	auth
f832f20a-5de7-4f18-b00c-e48eaf34c5fd	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T09:44:43.720Z	auth
daa9b5fd-8464-4a20-9d6e-99bb2fdb1f97	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T09:45:16.837Z	auth
e11e75f5-791a-4a29-b7a3-27214f744f57	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T09:46:06.632Z	auth
2e881301-4abb-40d4-97f4-4f5f4d4bc218	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:15:44.708Z	audit
562dd9ed-65bd-48a3-8ab8-4a64a2945e9e	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:15:57.369Z	audit
ba941a30-b46c-4615-94a5-9ab6599ca610	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:16:01.543Z	audit
6e749fa8-db36-45e9-b0ee-b7227638a91d	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:16:29.938Z	audit
bd5f5cd4-889d-473c-af3e-90b2b0e2fa26	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:16:42.464Z	audit
34a20ddc-763e-40b0-9461-4a53c921dd1f	LOGIN	FAIL email=superadmin@church.local reason=INVALID_CREDENTIALS ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:45:11.119Z	auth
73da509a-9030-414c-82f8-60621498cfc7	LOGIN	FAIL email=superadmin@church.local reason=INVALID_CREDENTIALS ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:45:46.021Z	auth
5fa97815-4e15-4224-b925-9939f97ef463	LOGIN	SUCCESS email=superadmin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:46:40.790Z	auth
15edaf96-2b58-431f-9ec7-26e8a950c0bd	POST /api/members	status=403 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:46:49.344Z	audit
601b9300-f248-4395-aacd-6adb32f48b85	POST /api/members	status=403 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:46:54.304Z	audit
0f565e79-3a09-494b-af69-7e5c108deca6	POST /api/members	status=403 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:47:06.960Z	audit
08d2140b-52fa-438f-8bcb-1c5abeccde7a	POST /api/members	status=200 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:47:50.628Z	audit
5185860d-0a99-434d-86fc-d5c8045c8add	REFRESH	SUCCESS ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:48:09.836Z	auth
0f86a4d1-8ac8-42ac-bb97-cafd7e7d8f07	REFRESH	FAIL reason=TOKEN_REUSE_DETECTED ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:48:16.594Z	auth
73e104ac-0c24-47b5-a271-7df17a04a07a	REFRESH	FAIL reason=TOKEN_REUSE_DETECTED ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:48:21.099Z	auth
68c651b3-2f50-4029-85a0-b83efed2e090	LOGIN	SUCCESS email=superadmin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T11:48:29.322Z	auth
2835a514-55f5-4055-a27d-97d1ac3033b0	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:54:07.304Z	auth
a2d09865-770d-4ca2-b4ae-1d30a98dc411	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:54:11.359Z	audit
02b9ff8d-6bca-4d58-9941-4dbfef639fa5	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:54:20.219Z	audit
b9eacaa2-85a3-45f7-bea0-bb56544d1081	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T11:54:29.666Z	audit
83900825-8503-4ef2-8c51-7ad99eec770c	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:01:12.685Z	audit
72520758-f4fa-458e-97d9-f45a597b9e76	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:01:37.507Z	audit
c04d7300-3f39-4b9e-9cda-19fafc88998a	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:01:48.759Z	audit
91bca92f-044f-43c7-a336-4ecd0c9cc59c	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:02:03.472Z	audit
56648a2a-e4e5-47a4-b325-44460c70f693	POST /api/users	status=200 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:13:50.952Z	audit
05eac3ef-18e5-4d12-8b58-b935e37ff7b7	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:02:36.005Z	audit
2cf28182-eaf9-4d18-a384-7512996cab7e	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:02:50.407Z	audit
70149f86-f963-4819-9ad3-0c71e4d62dd3	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:02:56.832Z	audit
6bb9dc7c-a7f8-4219-8a71-2a1ee77ffbb7	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:03:02.025Z	audit
870abbd6-a2f8-42f5-bd47-2eb379e3ea12	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:32:55.172Z	audit
c072f9e6-ee0f-4cac-ae93-cba8dbc2063f	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T12:57:05.583Z	audit
b0adce28-9123-42c6-a246-c8085fef96b9	PERMISSION_DENIED	permission=USER_CREATE user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/users?page=1&pageSize=500 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:07.947Z	security
f0540401-f83d-4153-8248-46a4244b1511	PERMISSION_DENIED	permission=PERMISSION_VIEW user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/permissions ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:07.954Z	security
a8c00885-64c4-43a1-b994-0b8933895166	PERMISSION_DENIED	permission=READ_ALL user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/groups ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:07.956Z	security
54050887-84b5-4004-8ace-52ddebc91b6d	PERMISSION_DENIED	permission=ROLE_VIEW user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/roles ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:07.968Z	security
54fc4571-7879-450f-8c84-96f9c2148880	PERMISSION_DENIED	permission=READ_ALL user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/members?page=1&pageSize=500 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:10.265Z	security
72f2633a-4287-4825-b57d-05733303074d	PERMISSION_DENIED	permission=BRANCH_UPDATE user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/branches?page=1&pageSize=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:10.271Z	security
a57c7251-3cc2-402e-a9d8-3325476e5a6f	PERMISSION_DENIED	permission=BRANCH_UPDATE user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/branches/pastors ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:10.272Z	security
af800c89-f6ac-4d51-859b-c50f89474f72	PERMISSION_DENIED	permission=SMS_SEND user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/sms/templates ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:11.851Z	security
bcfd662c-9dce-46a9-8a9c-7436b73bfc5f	PERMISSION_DENIED	permission=SMS_VIEW user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/sms?page=1&pageSize=20 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:11.851Z	security
ac5d4982-2221-4afb-9fbe-8e6a54361e62	PERMISSION_DENIED	permission=SMS_VIEW user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/sms/balance ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:11.853Z	security
3f725a45-5b76-449b-8c75-f4f043bafe57	PERMISSION_DENIED	permission=READ_ALL user=dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd path=/api/members?page=1&pageSize=300 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:11.854Z	security
6a473789-ec47-4310-a52d-921b08c8a8b5	POST /api/sms/balance	status=403 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:11.853Z	audit
74d38063-c479-49ff-900e-84a5840b396c	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T13:16:11.909Z	audit
b53adffc-9893-4b2d-bbd7-a827f51dc9ab	LOGIN	FAIL email=admin@church.local reason=NO_GROUP ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:05:08.911Z	auth
ecb040f2-a2f3-4fa7-82e3-433a1d58ecef	LOGIN	FAIL email=pastor@church.local reason=NO_GROUP ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:05:13.351Z	auth
9d9d4f22-b4ee-43a0-9d84-0d78a16462bc	LOGIN	FAIL email=ruth.wanjiru@church.local reason=NO_GROUP ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:05:16.920Z	auth
d1fc6d56-79b9-49fd-bf87-c21ba139e36d	REFRESH	SUCCESS ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T15:07:29.714Z	auth
573d76d7-66ea-475d-889c-fda1e6f48129	POST /api/metrics/ui-latency	status=200 ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T15:07:33.778Z	audit
144cdd91-534f-44da-a5f3-633f8d6d41ae	LOGIN	FAIL email=admin@church.local reason=NO_GROUP ip=127.0.0.1 ua=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-03-11T15:07:37.122Z	auth
34c2c31a-5024-4327-bf83-82e69187f3b2	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:10:29.293Z	auth
c9714768-a23d-42c0-83e5-e55784a74d66	LOGIN	SUCCESS email=admin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:11:23.251Z	auth
e7dc11bb-a8e6-4a8d-b658-89306284cc85	POST /api/users	status=400 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:11:35.014Z	audit
e40bac64-9141-47e4-be32-ffae081b93b1	POST /api/users	status=200 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:11:40.610Z	audit
237ec33f-a574-467e-a979-e0bb037393bc	LOGIN	SUCCESS email=wanjiru.super2@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:12:31.767Z	auth
a2c2c2dd-0bf0-438f-9736-ab228e9e9c01	LOGIN	FAIL email=admin@church.local reason=NO_GROUP ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:12:37.039Z	auth
ffa660f8-d270-45c7-84a9-3c8a88d0cccb	POST /api/groups	status=200 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:13:33.298Z	audit
e3822201-13e4-4fcc-a54f-e0eaafb2a683	POST /api/groups	status=200 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:13:33.294Z	audit
4498e9a7-36ff-416b-a9b3-eedd9e97e9c3	POST /api/users	status=200 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:13:39.687Z	audit
4909952c-73b4-4193-b7b4-5d8ec2674e8f	LOGIN	SUCCESS email=mary.akinyi@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:13:55.207Z	auth
08c2a2a3-95ca-46e7-be0b-6997da7d726e	PERMISSION_DENIED	permission=USER_CREATE user=1c09be18-bfd2-4a78-abdb-d39209ec7100 path=/api/users ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:15:39.544Z	security
2a5383f8-ec93-4571-b6db-397ca6955774	POST /api/users	status=400 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:16:55.725Z	audit
2ce0e7ae-216a-463d-a6d9-7845fb399b41	POST /api/sms/send	status=400 ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:15:27.253Z	audit
4d2a114a-6135-40de-ab33-ad39d7f0beaf	LOGIN	SUCCESS email=kamau.admin@church.local ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:15:32.044Z	auth
3fc2e4ab-8eff-4dac-94e3-ea089ee498cb	PERMISSION_DENIED	permission=BRANCH_UPDATE user=1c09be18-bfd2-4a78-abdb-d39209ec7100 path=/api/branches ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:15:39.547Z	security
41f31007-7ea7-4934-8435-2d0caa9aef2b	PERMISSION_DENIED	permission=USER_CREATE user=293be6b6-c24f-4fbe-9f09-e0c3cf477ac3 path=/api/users ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:18:47.861Z	security
fcb6a7ee-0efc-426e-979a-8eaf037d220f	PERMISSION_DENIED	permission=BRANCH_UPDATE user=293be6b6-c24f-4fbe-9f09-e0c3cf477ac3 path=/api/branches ip=127.0.0.1 ua=curl/7.81.0	2026-03-11T15:18:48.060Z	security
\.


--
-- Data for Name: branch_pastors; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.branch_pastors (id, branch_id, member_id, role) FROM stdin;
2032cef8-12ac-4c08-bdb7-293a15170ea9	69047316-0c00-42cd-99ba-af436d211b59	3a0218c7-554a-4342-8cad-a138701b0dca	Senior Pastor
03dcc702-581b-42d3-a5ea-d45d2b17257e	bfdb1267-4f28-4870-9eaf-352f3710d6dc	a45e59f5-bfd0-49d3-806b-90a68f1e1bf5	Associate Pastor
c7be82a1-abf8-46f4-b18d-f7ccc226a5a3	6a48ebc8-809e-4677-b54b-cb6861014713	73c90865-0666-48c5-831b-5fb7c44685ab	Youth Pastor
\.


--
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.branches (id, name, location, address, phone, email, status, created_by, created_at, last_edited_by, last_edited_at, sent_by) FROM stdin;
69047316-0c00-42cd-99ba-af436d211b59	PCC Main Campus	Nairobi	Kasarani	+254700000010	main@church.local	Active	system	2026-03-11T09:35:24.746Z	system	2026-03-11T09:35:24.746Z	\N
bfdb1267-4f28-4870-9eaf-352f3710d6dc	PCC Westlands	Nairobi	Westlands	+254700000011	westlands@church.local	Active	system	2026-03-11T09:35:24.746Z	system	2026-03-11T09:35:24.746Z	\N
6a48ebc8-809e-4677-b54b-cb6861014713	PCC Thika	Thika	Thika Road	+254700000012	thika@church.local	Active	system	2026-03-11T09:35:24.746Z	system	2026-03-11T09:35:24.746Z	\N
\.


--
-- Data for Name: committee_members; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.committee_members (id, committee_id, member_id, role) FROM stdin;
f5fb2a8c-fe73-40aa-b617-1ba2e6312829	3146786c-8d42-414d-b9af-a6987818575e	de2bb05a-ad45-4fd7-9581-7ba1764f53ad	Chair
9cf5770e-a8a0-475c-9a1b-8b064a466464	af7369ed-0931-411e-afa2-2514fa8c27d6	293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	Chair
9c59343a-5dbb-4b9d-aebe-83acdd0b757f	534677a7-d17a-4ab3-a004-57f2c4d0069f	b818dbc7-388b-4263-9b05-e118a9a1f341	Coordinator
6175586c-c9be-4e4f-a7aa-13f50557f6e6	7f974c34-bf63-4777-b923-c12e244538e8	46fbb0f6-118d-4758-b841-42a499b92969	Secretary
84f564ec-8495-4b43-aab3-2fef71929d09	24d1558c-75e8-48da-b220-dcd7a9ccb554	b401279c-6ade-4def-a173-4858beaa411a	Chair
a58b4787-b231-467d-820d-52c8f7a039dd	7f974c34-bf63-4777-b923-c12e244538e8	0715a7d7-9ca9-45ec-b2cc-7d07ba614d76	Member
34fa634f-a0e6-4419-b20a-c97ca783252f	3146786c-8d42-414d-b9af-a6987818575e	189cf488-3218-48fc-803d-10f2d1fdb7c8	Member
6f84a0a1-8e72-4b8a-842e-7025b285cf24	af7369ed-0931-411e-afa2-2514fa8c27d6	59b0c882-4d10-4aa8-b337-34698c628f24	Member
1f03f6ea-694e-4a3f-9c16-622bfbf1ea4e	534677a7-d17a-4ab3-a004-57f2c4d0069f	de2bb05a-ad45-4fd7-9581-7ba1764f53ad	Member
ffa4c110-287a-4bf6-9b1d-a04e4fb6afad	7f974c34-bf63-4777-b923-c12e244538e8	293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	Member
124a1658-5785-4070-8de0-b96576f7f334	3146786c-8d42-414d-b9af-a6987818575e	b401279c-6ade-4def-a173-4858beaa411a	Member
\.


--
-- Data for Name: committees; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.committees (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, description, name, status) FROM stdin;
3146786c-8d42-414d-b9af-a6987818575e	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Budget and stewardship	Finance Committee	Active
7f974c34-bf63-4777-b923-c12e244538e8	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Member care and follow-up	Pastoral Care Committee	Active
534677a7-d17a-4ab3-a004-57f2c4d0069f	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Facilities and projects	Building & Projects Committee	Active
24d1558c-75e8-48da-b220-dcd7a9ccb554	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Missions and partnerships	Missions Committee	Active
af7369ed-0931-411e-afa2-2514fa8c27d6	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Training and discipleship	Education & Discipleship Committee	Active
\.


--
-- Data for Name: department_members; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.department_members (id, department_id, member_id, role) FROM stdin;
838dc21f-291f-45b2-88fa-658026a76e07	84fc7f08-be74-487c-8e37-9382734b0484	de2bb05a-ad45-4fd7-9581-7ba1764f53ad	Leader
d2dbb2eb-ef41-41fa-b15b-70163de7749f	5e6f844c-e002-49a6-94a0-dfc334e10986	293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	Leader
e9b8f055-373e-42e9-b994-b91853bcd4d2	5da01ccc-2a8a-4dc7-94f4-deac5493cdb3	b818dbc7-388b-4263-9b05-e118a9a1f341	Coordinator
699d75b8-4582-4b24-a1bb-0fd3762b2f84	c2088c8a-395c-4640-8457-9b5d854a6864	46fbb0f6-118d-4758-b841-42a499b92969	Leader
0144aa08-5e23-43d7-ad5e-c3d5b43d85cb	85250359-576b-4a18-8227-aa0d4b28f7d1	b401279c-6ade-4def-a173-4858beaa411a	Leader
427cd50d-a43c-4406-895c-a7d043d61af5	0d4e1f8d-09df-4ba6-98df-5b5973bff572	0715a7d7-9ca9-45ec-b2cc-7d07ba614d76	Leader
c197802f-799d-439b-8651-b62ae56eaafd	140bb6eb-e7b6-443e-9711-c004249caba8	189cf488-3218-48fc-803d-10f2d1fdb7c8	Coordinator
110d33d0-7657-427c-8ce5-a950318389cd	aa98b455-b7f2-4079-8aa9-a6a3f093be3e	59b0c882-4d10-4aa8-b337-34698c628f24	Leader
e239d709-7dfa-40e8-b931-a1f704e8115e	b9babf01-eece-4615-b5e0-317d3d86d3fa	7e49d02c-53fa-43f1-9fd2-c8253964e6f9	Leader
f9380527-ddc2-43e8-96ba-1425feb790f8	fdcb71bd-17bf-461f-803c-ea4fbde3a292	30134799-913f-4f8e-ac16-78e7971db70d	Member
aaf3d9da-7e3c-49be-882d-c1f58b77484d	fdcb71bd-17bf-461f-803c-ea4fbde3a292	73c90865-0666-48c5-831b-5fb7c44685ab	Leader
94194cad-5af7-47b9-85b1-883ee741326d	5da01ccc-2a8a-4dc7-94f4-deac5493cdb3	b67ce892-1bb5-4967-bd81-488a39722945	Member
7e8e46be-247b-47ba-ba51-5e719a2e9762	c2088c8a-395c-4640-8457-9b5d854a6864	d2bbee57-7601-440e-8684-b383606bac79	Member
4c4f1e43-19b9-4869-b61f-b1c2d4737ecd	0d4e1f8d-09df-4ba6-98df-5b5973bff572	ad1d8478-d13c-43a7-9335-c5910979cbfb	Member
db997cd3-aa5c-4d13-afbb-8e5feb625b0e	5da01ccc-2a8a-4dc7-94f4-deac5493cdb3	de2bb05a-ad45-4fd7-9581-7ba1764f53ad	Member
7075d199-a998-4c93-b967-c54b842e3ed4	c2088c8a-395c-4640-8457-9b5d854a6864	293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	Member
d0992ac1-6a43-47a4-892f-871d31564a11	140bb6eb-e7b6-443e-9711-c004249caba8	b401279c-6ade-4def-a173-4858beaa411a	Member
62900b25-e4ad-496f-926a-49808c12544b	0d4e1f8d-09df-4ba6-98df-5b5973bff572	59b0c882-4d10-4aa8-b337-34698c628f24	Member
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.departments (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, description, leader, members_count, name, status) FROM stdin;
84fc7f08-be74-487c-8e37-9382734b0484	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Praise and worship ministry	\N	0	Worship & Choir	Active
fdcb71bd-17bf-461f-803c-ea4fbde3a292	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Youth discipleship and mentorship	\N	0	Youth Ministry	Active
85250359-576b-4a18-8227-aa0d4b28f7d1	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Hospitality and seating	\N	0	Ushering	Active
5da01ccc-2a8a-4dc7-94f4-deac5493cdb3	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Sound, projection, livestream	\N	0	Media & Audio	Active
5e6f844c-e002-49a6-94a0-dfc334e10986	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Kids church and teaching	\N	0	Children's Ministry	Active
0d4e1f8d-09df-4ba6-98df-5b5973bff572	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Prayer team	\N	0	Prayer & Intercession	Active
140bb6eb-e7b6-443e-9711-c004249caba8	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Community outreach	\N	0	Evangelism & Outreach	Active
b9babf01-eece-4615-b5e0-317d3d86d3fa	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Men's ministry	\N	0	Men's Fellowship	Active
aa98b455-b7f2-4079-8aa9-a6a3f093be3e	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Women's ministry	\N	0	Women's Fellowship	Active
c2088c8a-395c-4640-8457-9b5d854a6864	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	Visitor care and refreshments	\N	0	Hospitality	Active
\.


--
-- Data for Name: group_roles; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.group_roles (id, group_id, role_id) FROM stdin;
fa7e6b70-3f55-4dbb-bf59-d45b171214c1	c696730a-7cdc-42dd-bcb7-a94c1e48662b	7f2d3793-85aa-41ea-b3c7-4422a915a86f
e5cd0e18-6f65-4af7-98b1-e8f8ec3a47d2	eb91551f-576d-4e15-aa46-84448578daa5	7f2d3793-85aa-41ea-b3c7-4422a915a86f
9b5c58b8-34eb-4c54-8746-b5319ab9f449	8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d	7f2d3793-85aa-41ea-b3c7-4422a915a86f
c15ab798-ad5b-4413-979e-fbaf93eb9594	1810f63c-0eea-489c-afaf-464b326b0512	7f2d3793-85aa-41ea-b3c7-4422a915a86f
35883aa7-cf59-48bc-bfbe-338094185930	09f744fb-0fe1-4868-8b85-a45118bc2c44	7f2d3793-85aa-41ea-b3c7-4422a915a86f
9d7dc026-69ea-4b39-9821-71ba529680e3	32b47175-b886-4f60-a78a-65a76fc00ec1	7f2d3793-85aa-41ea-b3c7-4422a915a86f
5267ece6-6104-4b5d-a93c-f023eb53a814	0a2d3acf-876d-423d-9e62-661850890abf	7f2d3793-85aa-41ea-b3c7-4422a915a86f
15e0ce69-ee8d-4238-a944-924dd19ca927	a4520de0-16f7-49d6-83ab-138372873a60	7f2d3793-85aa-41ea-b3c7-4422a915a86f
306bccfe-ff77-4c4c-9eb0-cbc25d8f4eaa	e1cb962e-848b-4936-b9e7-d16a6b66a3f7	7f2d3793-85aa-41ea-b3c7-4422a915a86f
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.groups (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, description, name) FROM stdin;
c696730a-7cdc-42dd-bcb7-a94c1e48662b	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	System super administrators	Super Admins
eb91551f-576d-4e15-aa46-84448578daa5	2026-03-10T15:23:06.361893158+03:00	system	2026-03-10T15:23:06.468370789+03:00	system	\N	Updated by api-smoke	API Test Group Updated
8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d	2026-03-10T15:27:03.278034971+03:00	system	2026-03-10T15:27:03.361707526+03:00	system	\N	Updated by api-smoke	API Test Group Updated
1810f63c-0eea-489c-afaf-464b326b0512	2026-03-10T16:00:01.056307607+03:00	system	2026-03-10T16:00:01.122107954+03:00	system	\N	Updated test group	Test Group
09f744fb-0fe1-4868-8b85-a45118bc2c44	2026-03-10T16:00:14.955347670+03:00	system	2026-03-10T16:00:14.998763474+03:00	system	\N	Updated test group	Test Group
32b47175-b886-4f60-a78a-65a76fc00ec1	2026-03-10T16:02:04.078657036+03:00	system	2026-03-10T16:02:04.139519621+03:00	system	\N	Updated test group	Test Group 1773147723
0a2d3acf-876d-423d-9e62-661850890abf	2026-03-10T16:03:04.820445191+03:00	system	2026-03-10T16:03:04.861689496+03:00	system	\N	Updated test group	Test Group 1773147784
5f237b15-1bab-45c7-bb8c-3326a36b0003	2026-03-10T16:56:48.257272552+03:00	system	2026-03-10T16:56:48.257292732+03:00	system	\N	QA group	Test Group
a4520de0-16f7-49d6-83ab-138372873a60	2026-03-10T16:57:43.844686411+03:00	system	2026-03-10T16:57:43.844697816+03:00	system	\N	QA group	Test Group
e1cb962e-848b-4936-b9e7-d16a6b66a3f7	2026-03-10T17:06:58.078191627+03:00	system	2026-03-10T17:06:58.078222217+03:00	system	\N	QA group	Test Group
59fdb9ce-f8c7-460f-8ef9-58fd3294259d	2026-03-11T15:13:33.289Z	854b3e73-e9ed-4d78-9502-f43d05add677	2026-03-11T15:13:33.289Z	854b3e73-e9ed-4d78-9502-f43d05add677	\N	Admin group	Admins
57699093-83ec-4aef-b1a4-1c6118817520	2026-03-11T15:13:33.295Z	854b3e73-e9ed-4d78-9502-f43d05add677	2026-03-11T15:13:33.295Z	854b3e73-e9ed-4d78-9502-f43d05add677	\N	Leader group	Leaders
\.


--
-- Data for Name: latency_logs; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.latency_logs (id, source, method, path, status, duration_ms, "timestamp") FROM stdin;
b5bcf3dd-6c79-4538-af53-a62f43b00cb8	backend	POST	/api/auth/login	200	132	2026-03-11T09:36:07.869Z
65b0ce91-ff45-4f62-9f78-5290a0e1cca2	backend	GET	/api/reports/summary	200	28	2026-03-11T09:36:07.927Z
3fbb426e-1683-4511-b0e8-178d8c4c62d0	backend	GET	/api/reports/dashboard	200	45	2026-03-11T09:36:07.947Z
a06c314d-2e82-44e3-937e-2ac086c6cf48	backend	GET	/api/departments/roles	200	3	2026-03-11T09:36:10.857Z
927b647f-308f-48fd-a20f-fbad860a31ca	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	30	2026-03-11T09:36:10.878Z
bf3a8a45-de10-42ab-8c1e-4d400a77efaf	backend	GET	/api/committees/chairs	200	25	2026-03-11T09:36:10.884Z
8e759f9f-f6d5-41cb-9f1a-e2d57e0b0478	backend	GET	/api/committees?page=1&pageSize=200	200	38	2026-03-11T09:36:10.890Z
1ce85a07-0b7c-4561-addf-7298a8b63a64	backend	GET	/api/departments?page=1&pageSize=200	200	41	2026-03-11T09:36:10.891Z
55b09787-8ebc-42cd-8423-879705940c1b	backend	GET	/api/members?page=1&pageSize=500	200	44	2026-03-11T09:36:10.893Z
ac9940b9-fa1b-4e47-a5dd-8d49e5f68769	backend	GET	/api/departments/heads	200	42	2026-03-11T09:36:10.894Z
95849bbb-ddd9-498f-9569-d47bc5381fb5	backend	GET	/api/members/pastors	200	10	2026-03-11T09:36:10.895Z
debfe81b-89ec-4df2-a5bf-7af734859cc2	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	11	2026-03-11T09:36:10.924Z
16205024-a60f-453b-9606-d06a4076b6a1	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	19	2026-03-11T09:36:10.936Z
c83d5720-c1b7-4771-8e78-017a6565aff7	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	36	2026-03-11T09:36:10.951Z
db82f289-cba0-436e-8c93-7fc7ef4d9a7e	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	36	2026-03-11T09:36:10.951Z
02481d83-5935-4ced-9d0c-bc5e03ce0efe	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	33	2026-03-11T09:36:10.952Z
b159a660-75c3-4f62-a266-40268ef72eaf	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	36	2026-03-11T09:36:10.952Z
b1ced451-c662-4bcb-ac94-2c27fcda8530	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	14	2026-03-11T09:36:10.962Z
896f87a4-a9a3-4577-8e9d-48729700a782	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	5	2026-03-11T09:36:10.964Z
5c0ad082-7b7e-435b-8433-d8672e435101	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	9	2026-03-11T09:36:10.965Z
3578d526-0fea-4bbb-9094-ed581a649766	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	7	2026-03-11T09:36:10.966Z
8f348f03-a800-4d61-b11e-c7b2560a21d6	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	25	2026-03-11T09:36:11.010Z
acda7111-06cc-447b-9c58-be47e7ad62ea	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	28	2026-03-11T09:36:11.012Z
9369741b-93cb-4176-bd85-67a56839eeaf	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	32	2026-03-11T09:36:11.011Z
79c30496-6a7a-48c1-95dd-238fd46d418f	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	33	2026-03-11T09:36:11.013Z
b36fa42c-23c8-4ec5-929f-b1c81f004cac	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	32	2026-03-11T09:36:11.014Z
12f12f2c-843c-4d09-8a20-f17846f8be89	ui	NAV	/	200	99	2026-03-11T09:24:48.636Z
318616d4-e0ec-4d14-abc1-ad62da66e3ce	ui	NAV	/login	200	30	2026-03-11T09:24:48.814Z
12f5553b-b0d6-40c3-bda0-0c2f82eb7bcc	ui	NAV	/	200	9	2026-03-11T09:36:07.899Z
68e277d1-57dd-4e7b-a244-ed3c3d8ea087	ui	NAV	/membership	200	8	2026-03-11T09:36:10.839Z
f67e0be9-1861-4a23-a7f9-cb35128106a3	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986	200	8	2026-03-11T09:36:34.698Z
5bee9471-8579-4c57-a366-ff389cba1050	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=10	200	4	2026-03-11T09:36:34.718Z
59b696fa-ca87-4a0c-9212-685cdd01bd6d	ui	NAV	/membership/department/5e6f844c-e002-49a6-94a0-dfc334e10986	200	26	2026-03-11T09:36:34.691Z
2ceb3eea-abd5-464c-bf19-40be2534fb52	backend	GET	/api/sms/templates	200	85	2026-03-11T09:36:38.935Z
3e30b805-2b48-40c0-92db-a4ecd47886d8	backend	GET	/api/sms?page=1&pageSize=20	200	88	2026-03-11T09:36:38.940Z
1e1e59ec-db83-4a2c-bc5b-78cb3d555e68	backend	GET	/api/members?page=1&pageSize=300	200	89	2026-03-11T09:36:38.941Z
f2896ae9-02aa-4c41-ba6c-10a58c4f5634	backend	POST	/api/sms/balance	200	1007	2026-03-11T09:36:39.855Z
918dcfa9-17bc-43f3-a055-a8130fea7eea	ui	NAV	/sms	200	8	2026-03-11T09:36:38.844Z
16690caf-e514-4f86-9c97-7fc71d4b15de	backend	GET	/api/roles	200	7	2026-03-11T09:36:45.391Z
625daa7a-5bf1-42eb-a50f-259b5251aebd	backend	GET	/api/users?page=1&pageSize=500	200	11	2026-03-11T09:36:45.392Z
aee0cfc0-e922-422e-9aef-adc83d391aa4	backend	GET	/api/groups	200	10	2026-03-11T09:36:45.392Z
ca988535-38dd-4652-ab74-c3e148f1f375	backend	GET	/api/permissions	200	10	2026-03-11T09:36:45.393Z
cf8d3658-e527-43fd-b6b4-05cdd912edb4	backend	GET	/api/groups/1810f63c-0eea-489c-afaf-464b326b0512/roles	200	6	2026-03-11T09:36:45.445Z
4d8036f4-42bc-48a3-bb55-e247c3980274	backend	GET	/api/groups/e1cb962e-848b-4936-b9e7-d16a6b66a3f7/roles	200	5	2026-03-11T09:36:45.446Z
851f85dc-dd77-482f-9e60-e426104e02cb	backend	GET	/api/groups/c696730a-7cdc-42dd-bcb7-a94c1e48662b/roles	200	11	2026-03-11T09:36:45.447Z
303978fa-c044-4e89-9b08-74e41ed1610b	backend	GET	/api/groups/eb91551f-576d-4e15-aa46-84448578daa5/roles	200	10	2026-03-11T09:36:45.447Z
8c1e1b60-645e-4c3a-8e69-d64e6dbd99a1	backend	GET	/api/groups/8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d/roles	200	9	2026-03-11T09:36:45.448Z
e298111d-8645-4fe7-a49c-89295d380cc1	backend	GET	/api/groups/09f744fb-0fe1-4868-8b85-a45118bc2c44/roles	200	7	2026-03-11T09:36:45.448Z
b20d6da5-33a7-45b1-82dd-73fed6363e51	backend	GET	/api/groups/32b47175-b886-4f60-a78a-65a76fc00ec1/roles	200	8	2026-03-11T09:36:45.464Z
b9fc9fe1-efc4-4379-8b51-998d2cd7c2f1	backend	GET	/api/groups/5f237b15-1bab-45c7-bb8c-3326a36b0003/roles	200	6	2026-03-11T09:36:45.465Z
56225c7f-8349-47f8-9190-db208358c0a0	backend	GET	/api/groups/a4520de0-16f7-49d6-83ab-138372873a60/roles	200	5	2026-03-11T09:36:45.466Z
82c8136e-c26a-4f93-aff0-808c5aad5a68	backend	GET	/api/groups/0a2d3acf-876d-423d-9e62-661850890abf/roles	200	7	2026-03-11T09:36:45.464Z
be543389-94a6-4498-a178-a62cdee7a180	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd/groups	200	11	2026-03-11T09:36:45.518Z
89dc6499-ea8f-4528-974b-e2cd123c5496	backend	GET	/api/users/2fef893c-6fd1-4929-92e7-b6af0cec4132/groups	200	8	2026-03-11T09:36:45.519Z
0b89a531-befc-4cb5-96dd-bc1bf5add441	backend	GET	/api/users/528c4843-72f8-413e-a09c-80167d54378b/groups	200	7	2026-03-11T09:36:45.519Z
efcd3947-ea74-4bb4-a76c-66ad12faf0f8	backend	GET	/api/roles/7f2d3793-85aa-41ea-b3c7-4422a915a86f/permissions	200	15	2026-03-11T09:36:45.552Z
fa2ce7f7-596f-4fe2-a1bb-33ed7e83920e	backend	GET	/api/committees/chairs	200	17	2026-03-11T12:01:44.879Z
f4820c67-c2b1-4ad2-855c-46a61284dc70	backend	GET	/api/roles/1badaed8-e034-4fbc-9444-00dccf064485/permissions	200	13	2026-03-11T09:36:45.579Z
e318799f-3558-48e6-832e-ebe5861217f5	backend	GET	/api/reports/summary	200	21	2026-03-11T09:36:47.389Z
883f0ade-c4af-4647-81e3-91aad2f5362a	ui	NAV	/users	200	18	2026-03-11T09:36:45.386Z
06ce10eb-d2c1-4ad9-b505-e9f3395ddbc5	ui	NAV	/reports	200	17	2026-03-11T09:36:47.370Z
bf424c4b-bf68-4c24-9540-d6fb22df055e	backend	GET	/api/roles/5a9f8573-998f-4c4f-a13b-e68b205bf2a3/permissions	200	10	2026-03-11T09:36:45.581Z
0bf7af14-f1d4-4a5f-8605-f269e4f19d01	backend	GET	/api/branches/pastors	200	4	2026-03-11T09:38:25.411Z
e6fab8ac-6d17-47ab-8fbb-4073f840ba92	backend	POST	/api/auth/login	200	151	2026-03-11T09:44:31.155Z
59484b85-4472-4f71-a1a6-1dc41e9adcdb	backend	GET	/api/branches	401	1	2026-03-11T09:44:31.218Z
eeffd804-1136-4d80-a765-0daea939069e	backend	POST	/api/auth/login	200	103	2026-03-11T09:44:43.721Z
ca237fee-17db-43f7-8b9c-6e083b89bdbb	backend	POST	/api/auth/login	200	138	2026-03-11T09:45:16.838Z
03faa110-a988-478b-bbb7-cbb4aa779a31	backend	GET	/api/branches	200	11	2026-03-11T09:45:16.890Z
8cf76b13-e384-48f6-a0ff-e16375354851	backend	GET	/api/branches	200	5	2026-03-11T09:45:16.901Z
fed56253-2c43-4471-b25c-356283e86226	backend	GET	/api/branches/69047316-0c00-42cd-99ba-af436d211b59	200	4	2026-03-11T09:45:16.932Z
7b622d10-659f-4ef9-bb2a-0a58724ce601	backend	GET	/api/branches/69047316-0c00-42cd-99ba-af436d211b59/pastors	200	4	2026-03-11T09:45:16.955Z
77379e84-5485-4269-89c2-c59947efeb55	backend	GET	/api/branches/pastors	200	4	2026-03-11T09:45:16.973Z
adbd2bb6-2a82-41d1-a820-6394f4ec9f7d	ui	NAV	/login	200	123	2026-03-11T10:00:00.000Z
562f778e-a4e9-489c-905d-7dc235605a0c	backend	POST	/api/auth/login	200	112	2026-03-11T09:46:06.634Z
88325010-a5e3-49a1-af3e-f9f0a261d283	backend	GET	/api/reports/summary	200	16	2026-03-11T09:46:06.672Z
4697b90b-e4ca-4178-a268-b08b01d7d6b2	backend	GET	/api/reports/dashboard	200	25	2026-03-11T09:46:06.678Z
77a0f5d5-fc5e-4379-b495-e791df904cd7	ui	NAV	/	200	15	2026-03-11T09:42:40.691Z
57ea2977-3508-4ef2-aa77-403dd3e8eadd	ui	NAV	/login	200	12	2026-03-11T09:42:40.774Z
527f74d5-1346-4e1c-9f79-9382605ce089	ui	NAV	/	200	21	2026-03-11T09:46:06.668Z
dde8db52-397d-47b0-8308-ac4c165a9662	backend	GET	/api/sms/templates	200	46	2026-03-11T09:46:20.046Z
5a1c8fb1-b9f7-4592-8904-75ce68da15a5	backend	GET	/api/members?page=1&pageSize=300	200	54	2026-03-11T09:46:20.058Z
753db65b-98b0-463f-bd8d-c60e9d56166d	backend	GET	/api/sms?page=1&pageSize=20	200	59	2026-03-11T09:46:20.061Z
0ca8ca6d-43e3-4113-81bf-13c4eda530f1	backend	POST	/api/sms/balance	200	693	2026-03-11T09:46:20.691Z
f1fe3747-1246-43a3-baf0-23b65df1ef6d	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	13	2026-03-11T09:46:22.495Z
c3b6d483-48d8-4fd8-bea8-f67bdb395eb5	backend	GET	/api/committees?page=1&pageSize=200	200	10	2026-03-11T09:46:22.496Z
86324543-dd88-4b4a-a5f0-0cc3197b8d65	backend	GET	/api/members?page=1&pageSize=500	200	19	2026-03-11T09:46:22.503Z
f5a75ae2-a9f4-4a83-8612-d97d6d81fff7	backend	GET	/api/departments/roles	200	18	2026-03-11T09:46:22.506Z
4299223a-f43a-4517-8880-8c9d4fc26860	backend	GET	/api/departments?page=1&pageSize=200	200	23	2026-03-11T09:46:22.512Z
bea967ab-88df-46cd-b29d-299d58a205b1	backend	GET	/api/committees/chairs	200	14	2026-03-11T09:46:22.512Z
8089f7c3-291e-4e80-8576-ddf015183980	backend	GET	/api/members/pastors	200	12	2026-03-11T09:46:22.512Z
631c4ea0-561c-46db-9c53-5f5794a76296	backend	GET	/api/departments/heads	200	26	2026-03-11T09:46:22.513Z
69d43085-15b1-4bd1-9ca6-c66187f73634	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	13	2026-03-11T09:46:22.547Z
1f96ed86-7d53-4219-af93-d740284045e3	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	8	2026-03-11T09:46:22.549Z
990d719e-c3e8-4ddc-a718-cb4d66180b1d	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	15	2026-03-11T09:46:22.551Z
7f6fcb98-ec8d-465b-ad76-2bea640a66ad	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	13	2026-03-11T09:46:22.551Z
2dbf9e66-4e0c-489c-bae7-92555a3e8642	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	11	2026-03-11T09:46:22.551Z
c72625e9-e929-412b-bbba-f88c8ee00753	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	10	2026-03-11T09:46:22.552Z
5e950071-96c3-4aa2-b524-463ea375574d	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	8	2026-03-11T09:46:22.558Z
226354ca-311f-46eb-a7ed-9ce3121c95ef	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	6	2026-03-11T09:46:22.561Z
557043fd-2912-4937-ac4c-4922319a257f	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	8	2026-03-11T09:46:22.560Z
65bcc2bf-b92e-4864-bf3d-524e417b4e27	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	7	2026-03-11T09:46:22.564Z
2aa59f57-98cc-4cd5-903d-5e0c93cc4465	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	8	2026-03-11T09:46:22.587Z
2bb799d9-2f0f-46ef-afb3-61cb2d18e1f1	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	12	2026-03-11T09:46:22.588Z
255f072a-8335-47e5-8b5e-95260a6a26e7	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	9	2026-03-11T09:46:22.589Z
0507b1a3-d438-497e-826a-9795bf1289f4	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	12	2026-03-11T09:46:22.589Z
3a47728c-81a1-4e90-b55e-1a45e1f76987	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	14	2026-03-11T09:46:22.590Z
5bb7a868-a3dc-484e-9bd3-b796ade99569	ui	NAV	/sms	200	6	2026-03-11T09:46:19.994Z
5438193c-8c6b-4af9-9486-fcd038b9dc3e	ui	NAV	/membership	200	9	2026-03-11T09:46:22.477Z
592b7f9f-a2ef-4257-8a5e-b22d61df02b9	backend	GET	/api/branches/pastors	200	3	2026-03-11T09:46:24.124Z
46764c53-003a-47fd-b48c-f197cdaca15d	backend	GET	/api/branches?page=1&pageSize=200	200	6	2026-03-11T09:46:24.125Z
1b76fe2a-bec2-4da5-b6ee-4a5af2fb4990	ui	NAV	/branches	200	22	2026-03-11T09:46:24.133Z
07ed6afb-c578-4325-a301-ff26f3e36f30	backend	GET	/api/branches/69047316-0c00-42cd-99ba-af436d211b59	200	4	2026-03-11T09:46:37.859Z
706d5ce9-5271-425f-bb0b-2daa1e46d3f3	backend	GET	/api/branches/6a48ebc8-809e-4677-b54b-cb6861014713	200	4	2026-03-11T09:47:07.237Z
55a03e25-8d06-4073-9eb1-c8ee9d132814	backend	GET	/api/roles	200	4	2026-03-11T09:47:14.078Z
7efacd2f-edf3-427c-90ae-020e28e069ba	backend	GET	/api/users?page=1&pageSize=500	200	8	2026-03-11T09:47:14.079Z
77f94d79-8757-4fde-9364-43b310ab42ff	backend	GET	/api/groups	200	7	2026-03-11T09:47:14.080Z
a59f227a-4d6d-452a-8c4e-5a726f921c90	backend	GET	/api/permissions	200	6	2026-03-11T09:47:14.081Z
f0b98396-760e-457d-ad1f-e1e4b2e0b873	backend	GET	/api/groups/c696730a-7cdc-42dd-bcb7-a94c1e48662b/roles	200	8	2026-03-11T09:47:14.102Z
0f28e045-77f9-40b6-81fb-d33e79b08ed9	backend	GET	/api/groups/eb91551f-576d-4e15-aa46-84448578daa5/roles	200	11	2026-03-11T09:47:14.111Z
bfe466c2-538f-41b9-a293-fab45b620880	backend	GET	/api/groups/8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d/roles	200	10	2026-03-11T09:47:14.114Z
37064fde-abd4-4885-ba25-f623ee4e1a28	backend	GET	/api/groups/1810f63c-0eea-489c-afaf-464b326b0512/roles	200	10	2026-03-11T09:47:14.114Z
c7f5faa9-1605-4e79-b771-b1190f3138ff	backend	GET	/api/groups/09f744fb-0fe1-4868-8b85-a45118bc2c44/roles	200	9	2026-03-11T09:47:14.116Z
8d6d456c-7b7f-4774-9a78-9374071f7db8	backend	GET	/api/groups/5f237b15-1bab-45c7-bb8c-3326a36b0003/roles	200	12	2026-03-11T09:47:14.131Z
64b9301c-feb4-454a-b486-f7187a9f632c	backend	GET	/api/users/528c4843-72f8-413e-a09c-80167d54378b/groups	200	5	2026-03-11T09:47:14.155Z
829b69d8-300c-4af9-adc2-484733e57838	backend	GET	/api/groups/32b47175-b886-4f60-a78a-65a76fc00ec1/roles	200	9	2026-03-11T09:47:14.117Z
8f708ab6-849a-4dfd-97b3-38fc2e889fce	backend	GET	/api/users/2fef893c-6fd1-4929-92e7-b6af0cec4132/groups	200	6	2026-03-11T09:47:14.154Z
ab5e8580-e4bc-4d98-8864-408f62a21f19	backend	GET	/api/roles/5a9f8573-998f-4c4f-a13b-e68b205bf2a3/permissions	200	4	2026-03-11T09:47:14.172Z
13a3f341-8267-4647-b9f7-08af2847e750	backend	GET	/api/reports/summary	200	5	2026-03-11T09:47:19.695Z
70fd85d7-60b3-460d-b52b-2d195db1922d	ui	NAV	/reports	200	5	2026-03-11T09:47:19.686Z
451022ad-5238-4eb9-a704-6a52defde818	backend	GET	/api/groups/0a2d3acf-876d-423d-9e62-661850890abf/roles	200	8	2026-03-11T09:47:14.118Z
99f214e0-4f65-443b-95da-d29dd696257b	backend	GET	/api/groups/a4520de0-16f7-49d6-83ab-138372873a60/roles	200	12	2026-03-11T09:47:14.133Z
0d64b28d-d4cb-41cd-8118-7efd69fb1937	backend	GET	/api/groups/e1cb962e-848b-4936-b9e7-d16a6b66a3f7/roles	200	12	2026-03-11T09:47:14.135Z
7ee25f9a-4182-4492-ae51-4e93172709ed	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd/groups	200	6	2026-03-11T09:47:14.154Z
9a1ee7fe-2184-4ac0-850e-c9297aa2838c	backend	GET	/api/roles/1badaed8-e034-4fbc-9444-00dccf064485/permissions	200	5	2026-03-11T09:47:14.171Z
049febf7-4307-474d-b24d-a04179d353a4	backend	GET	/api/roles/7f2d3793-85aa-41ea-b3c7-4422a915a86f/permissions	200	8	2026-03-11T09:47:14.174Z
ab92680d-356f-4cb4-b792-74384c1cd297	ui	NAV	/users	200	20	2026-03-11T09:47:14.081Z
5e918770-1a96-4eb1-b3be-363a3bb65f68	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	200	3	2026-03-11T09:48:07.617Z
334ddfc6-d389-4746-a29a-3f5834c79393	backend	GET	/api/reports/summary	200	9	2026-03-11T09:48:10.474Z
7f066972-d6c3-46e1-8fda-3f020ce4aac3	ui	NAV	/profile	200	28	2026-03-11T09:48:07.634Z
d3f854ac-4673-47dd-8a78-6d54560e362c	ui	NAV	/reports	200	9	2026-03-11T09:48:10.467Z
6bfa87fc-1ab1-41bb-97ad-770bd03cc1ba	backend	GET	/api/roles	200	3	2026-03-11T09:48:12.539Z
ebe0df76-8e4a-470b-b849-a098ba663f3c	backend	GET	/api/permissions	200	4	2026-03-11T09:48:12.541Z
81984f92-84a5-421b-a5e1-926d8abbbbe2	backend	GET	/api/users?page=1&pageSize=500	200	8	2026-03-11T09:48:12.541Z
6287ad28-ac4b-43e4-b39f-7205983f2728	backend	GET	/api/groups	200	7	2026-03-11T09:48:12.542Z
29f52805-a7c7-4d90-b0d8-ad82db7ca86d	backend	GET	/api/groups/c696730a-7cdc-42dd-bcb7-a94c1e48662b/roles	200	10	2026-03-11T09:48:12.569Z
ef9e0452-ebb6-4d70-803a-8e27383ff3fa	backend	GET	/api/groups/eb91551f-576d-4e15-aa46-84448578daa5/roles	200	9	2026-03-11T09:48:12.569Z
030bd7fb-e0dd-4483-8c08-ac9c42f8e037	backend	GET	/api/groups/8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d/roles	200	8	2026-03-11T09:48:12.570Z
95a3096a-8aad-4663-a130-6a62faff9cf7	backend	GET	/api/groups/1810f63c-0eea-489c-afaf-464b326b0512/roles	200	7	2026-03-11T09:48:12.571Z
eb69a2de-591a-46f2-a53b-42c3d1320cbb	backend	GET	/api/groups/32b47175-b886-4f60-a78a-65a76fc00ec1/roles	200	6	2026-03-11T09:48:12.571Z
6205699a-b49a-4b70-9568-e58f0064abdf	backend	GET	/api/groups/09f744fb-0fe1-4868-8b85-a45118bc2c44/roles	200	8	2026-03-11T09:48:12.572Z
1fe26d4b-2aa6-4b4d-812b-5fd63eb78aa6	backend	GET	/api/groups/5f237b15-1bab-45c7-bb8c-3326a36b0003/roles	200	5	2026-03-11T09:48:12.580Z
e8768f07-d15e-4392-90f6-d2d756fdd536	backend	GET	/api/groups/a4520de0-16f7-49d6-83ab-138372873a60/roles	200	5	2026-03-11T09:48:12.581Z
c088c6c9-9ac5-4ec4-85df-a01c59663cf1	backend	GET	/api/groups/0a2d3acf-876d-423d-9e62-661850890abf/roles	200	9	2026-03-11T09:48:12.582Z
85699f2e-566e-4e63-a642-3648d63e0d8d	backend	GET	/api/groups/e1cb962e-848b-4936-b9e7-d16a6b66a3f7/roles	200	5	2026-03-11T09:48:12.583Z
a92bf089-abb5-4eff-886a-32185481878c	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd/groups	200	6	2026-03-11T09:48:12.599Z
a5fefefc-3b9c-47b0-93d2-087ac204b118	backend	GET	/api/users/2fef893c-6fd1-4929-92e7-b6af0cec4132/groups	200	5	2026-03-11T09:48:12.600Z
57beeaa0-ce0f-40ce-8016-e1a9b5a8f671	backend	GET	/api/users/528c4843-72f8-413e-a09c-80167d54378b/groups	200	7	2026-03-11T09:48:12.603Z
c7855e9e-1f4f-4c54-8c74-bf4a2ced681c	backend	GET	/api/roles/1badaed8-e034-4fbc-9444-00dccf064485/permissions	200	5	2026-03-11T09:48:12.619Z
76ef54be-bb82-4574-9c60-c5c650450c84	backend	GET	/api/roles/7f2d3793-85aa-41ea-b3c7-4422a915a86f/permissions	200	7	2026-03-11T09:48:12.620Z
ddb0dedf-f082-4a05-a0c3-ef1d5e718abe	backend	GET	/api/roles/5a9f8573-998f-4c4f-a13b-e68b205bf2a3/permissions	200	6	2026-03-11T09:48:12.621Z
6420cead-d265-44da-aef7-f863c720bb6c	backend	GET	/api/branches/pastors	200	4	2026-03-11T09:48:14.772Z
9326b539-f759-4b7c-a08f-12bb257c41e3	backend	GET	/api/branches?page=1&pageSize=200	200	5	2026-03-11T09:48:14.775Z
e222ec80-2f1e-43af-a29d-bdbc0da88779	ui	NAV	/users	200	26	2026-03-11T09:48:12.551Z
273f86ac-02d9-444d-a348-93a009499874	ui	NAV	/branches	200	13	2026-03-11T09:48:14.767Z
d4f0a029-0d4a-4659-8e01-669c4b41a248	ui	NAV	/reports	200	37	2026-03-11T09:48:18.339Z
d2c4e4a5-e1d1-4486-8af2-5225eb2c1d1c	backend	GET	/api/reports/summary	200	4	2026-03-11T09:48:44.527Z
9e272238-7812-4067-8e97-c00c6d9f6438	backend	GET	/api/reports/dashboard	200	9	2026-03-11T09:48:44.531Z
23107e78-80d2-4386-b60e-9b47752e8c4c	ui	NAV	/	200	4	2026-03-11T09:48:44.517Z
503040d5-872c-42d1-b204-99e056403b40	backend	GET	/api/reports/dashboard-full	200	63	2026-03-11T09:48:55.296Z
678f8d2e-3fb0-4e5a-bb79-75b7deeb9328	backend	GET	/api/branches/pastors	200	4	2026-03-11T09:49:02.211Z
a3a18763-14e2-4f48-8886-12619cb4f38e	backend	GET	/api/branches?page=1&pageSize=200	200	18	2026-03-11T09:49:02.222Z
3590b79c-b20e-41f8-9445-fd0b64622d12	backend	GET	/api/branches/69047316-0c00-42cd-99ba-af436d211b59	200	7	2026-03-11T09:49:05.571Z
dc6e95fb-89be-46ff-a390-2730565a0768	ui	NAV	/branches	200	9	2026-03-11T09:49:02.200Z
c9ffa00c-657b-47df-a82f-8e9dfa456b36	backend	GET	/api/branches/bfdb1267-4f28-4870-9eaf-352f3710d6dc	200	5	2026-03-11T09:49:18.187Z
43e6689a-91be-4c03-a34e-2a7f80cda78f	backend	GET	/api/users?page=1&pageSize=500	200	9	2026-03-11T09:49:22.133Z
fe580445-85c0-4a81-b1e2-aaa8923a7f89	backend	GET	/api/permissions	200	16	2026-03-11T09:49:22.144Z
98406c9a-5b76-4f11-aee3-fadc904b9ec0	backend	GET	/api/groups	200	20	2026-03-11T09:49:22.145Z
1e2fc4e5-ace5-4bc9-95db-3261a16efedf	backend	GET	/api/roles	200	20	2026-03-11T09:49:22.146Z
8fcbbbdb-0e4f-41b2-8ffc-8dac7b61dc9d	backend	GET	/api/groups/c696730a-7cdc-42dd-bcb7-a94c1e48662b/roles	200	8	2026-03-11T09:49:22.163Z
6fe3b473-8e91-4a38-ada0-162b9f10b950	backend	GET	/api/groups/eb91551f-576d-4e15-aa46-84448578daa5/roles	200	8	2026-03-11T09:49:22.164Z
bac267d8-ed2b-47b4-ada8-edcedc1dcf66	backend	GET	/api/groups/8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d/roles	200	9	2026-03-11T09:49:22.179Z
8b067298-face-467c-8cab-fa73f4a87cfe	backend	GET	/api/groups/09f744fb-0fe1-4868-8b85-a45118bc2c44/roles	200	8	2026-03-11T09:49:22.180Z
e0926e24-afcc-4732-b3e3-9091c44a88c8	backend	GET	/api/groups/32b47175-b886-4f60-a78a-65a76fc00ec1/roles	200	7	2026-03-11T09:49:22.180Z
fc7239f6-42dd-4828-9808-49057d9b5aab	backend	GET	/api/groups/0a2d3acf-876d-423d-9e62-661850890abf/roles	200	7	2026-03-11T09:49:22.181Z
b6c7c0d5-05e4-49b2-9f75-b457845f8866	backend	GET	/api/groups/5f237b15-1bab-45c7-bb8c-3326a36b0003/roles	200	6	2026-03-11T09:49:22.181Z
eaee0fa3-c7ee-460d-a197-561d68ae9c5a	backend	GET	/api/groups/a4520de0-16f7-49d6-83ab-138372873a60/roles	200	5	2026-03-11T09:49:22.190Z
6da559ac-0c27-460c-92b3-9e4199d8f5f1	backend	GET	/api/groups/e1cb962e-848b-4936-b9e7-d16a6b66a3f7/roles	200	5	2026-03-11T09:49:22.191Z
9cd52a02-20e0-45a9-969d-a3905cfdd4a2	backend	GET	/api/groups/1810f63c-0eea-489c-afaf-464b326b0512/roles	200	11	2026-03-11T09:49:22.182Z
7ffdf865-c069-48e8-9e01-9d7aa06eedbf	backend	GET	/api/users/2fef893c-6fd1-4929-92e7-b6af0cec4132/groups	200	5	2026-03-11T09:49:22.209Z
a0484447-c519-413d-9b51-df4946ce0e9e	backend	GET	/api/users?page=1&pageSize=500	403	44	2026-03-11T13:16:07.950Z
5120fd7b-7e7e-47aa-867f-e729fe5bc9ec	backend	GET	/api/users/528c4843-72f8-413e-a09c-80167d54378b/groups	200	4	2026-03-11T09:49:22.210Z
b0a11412-d768-451d-a263-32bdf0ad0d12	backend	GET	/api/roles/5a9f8573-998f-4c4f-a13b-e68b205bf2a3/permissions	200	4	2026-03-11T09:49:22.230Z
3ca0281a-d0d9-4c27-ab0e-7c9bb1172d5d	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd/groups	200	8	2026-03-11T09:49:22.210Z
ca5572c3-8dc3-4d14-b764-169fd44ccd55	backend	GET	/api/roles/1badaed8-e034-4fbc-9444-00dccf064485/permissions	200	4	2026-03-11T09:49:22.229Z
c8fe5ed4-75b6-41d4-86c1-c0a4ba191f91	backend	GET	/api/roles/7f2d3793-85aa-41ea-b3c7-4422a915a86f/permissions	200	7	2026-03-11T09:49:22.231Z
bab4b7bf-12d9-465f-abee-1ffe8559ae2f	backend	GET	/api/reports/summary	200	8	2026-03-11T09:49:25.752Z
8b769deb-5163-418a-933c-7ed460326110	ui	NAV	/users	200	7	2026-03-11T09:49:22.117Z
2642ef9f-cc73-42c1-8474-1c4c61b641aa	ui	NAV	/reports	200	4	2026-03-11T09:49:25.740Z
a65363cc-7661-4663-bbcf-fd9fc8a9d001	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	200	4	2026-03-11T09:49:27.008Z
36f4016f-f7ad-42c3-9888-f5d9e1715ef2	ui	NAV	/profile	200	24	2026-03-11T09:49:27.020Z
5c5627ca-5181-4e09-a8af-9da78608a15a	backend	GET	/api/departments/roles	200	34	2026-03-11T11:15:40.724Z
3f050acf-27d3-456b-8060-9d51bb7f5cea	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	62	2026-03-11T11:15:40.738Z
d17d1a8f-856b-4ba5-90cb-dea8925e54d8	backend	GET	/api/members?page=1&pageSize=500	200	56	2026-03-11T11:15:40.739Z
88c7bb68-96fb-4a27-a0b5-799925ae8870	backend	GET	/api/committees/chairs	200	65	2026-03-11T11:15:40.750Z
dc7eed23-3a2b-4b84-9273-53597372ef80	backend	GET	/api/committees?page=1&pageSize=200	200	66	2026-03-11T11:15:40.754Z
c8a4cacb-90dc-4e2a-81a9-e8b84a8b4287	backend	GET	/api/departments?page=1&pageSize=200	200	69	2026-03-11T11:15:40.756Z
d7a7839f-566a-40ab-bbb0-259b907b52f4	backend	GET	/api/departments/heads	200	26	2026-03-11T11:15:40.761Z
cc861bcd-40ca-4bd3-9300-978821cf24cd	backend	GET	/api/members/pastors	200	10	2026-03-11T11:15:40.762Z
40993902-7a98-4b8b-9345-3bc701c278a4	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	19	2026-03-11T11:15:40.795Z
0a1fb197-f697-4657-8f36-d316bcc6f14d	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	11	2026-03-11T11:15:40.804Z
f8839769-4a29-4ccc-92ad-b93391836fc7	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	15	2026-03-11T11:15:40.805Z
ac732f22-1bc5-41de-af18-d5e2dbf136d5	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	14	2026-03-11T11:15:40.805Z
b2411146-4759-43ad-b38a-ea5fb0667ccb	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	19	2026-03-11T11:15:40.807Z
989c0f16-385d-4c3d-975e-58b7aca62f39	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	16	2026-03-11T11:15:40.809Z
de56bfea-9a8b-4a83-a1b3-338274e74773	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	15	2026-03-11T11:15:40.813Z
aabbb42b-75af-467e-946e-7e8c9dbe7f53	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	14	2026-03-11T11:15:40.821Z
c441e0da-ab43-45c8-a44c-a16fab72ea69	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	14	2026-03-11T11:15:40.824Z
d0e2bf6c-80d4-4138-9ef9-6a14a29c64c4	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	15	2026-03-11T11:15:40.827Z
e3eb8c16-7226-42d3-9a1e-44a93195d17b	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	25	2026-03-11T11:15:40.883Z
018faac8-b025-469c-b10d-47e2c57ee0d0	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	28	2026-03-11T11:15:40.885Z
39fa8bee-68f3-4613-b05a-58dbb08fcc5e	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	30	2026-03-11T11:15:40.888Z
679c890c-691d-4c3f-8efb-80bbba609e9c	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	34	2026-03-11T11:15:40.889Z
eea38d0b-7971-4663-8b04-ac60b645f195	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	33	2026-03-11T11:15:40.890Z
914cb381-c917-4a5e-ab0e-e635b68def3c	ui	NAV	/membership	200	9	2026-03-11T11:15:40.661Z
c0ed83d9-281c-41b0-9690-d6f821f3f5fd	backend	GET	/api/committees/roles	200	34	2026-03-11T11:15:53.423Z
fbf76f12-df3f-4b7c-89d7-b42296778dca	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6	200	47	2026-03-11T11:15:53.430Z
8e27b4c4-5eac-4a2d-8c74-6da1de080beb	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=10	200	11	2026-03-11T11:15:53.452Z
eb5a8f3b-76ab-4f36-a784-ae92682bae36	ui	NAV	/membership/committee/af7369ed-0931-411e-afa2-2514fa8c27d6	200	11	2026-03-11T11:15:53.352Z
5aa2ffd1-ef11-4bc7-a758-5c90e9103bf1	ui	NAV	/membership	200	16	2026-03-11T11:15:57.537Z
6ce8ada7-8087-4015-b624-54ad333a9863	backend	GET	/api/branches/pastors	200	4	2026-03-11T11:16:25.857Z
ac7a5e76-8317-4ff6-8a0b-a480b0243683	backend	GET	/api/branches?page=1&pageSize=200	200	7	2026-03-11T11:16:25.859Z
4f2d05c6-059a-40db-bcf2-66e5e11e4c17	ui	NAV	/branches	200	27	2026-03-11T11:16:25.867Z
6417427d-a840-4fe0-a1c6-24896774dcc8	backend	GET	/api/users?page=1&pageSize=500	200	10	2026-03-11T11:16:38.468Z
654f5334-5a44-4199-afae-ded2fb898046	backend	GET	/api/roles	200	12	2026-03-11T11:16:38.473Z
b4d61bab-0d6d-43ed-83ef-bf585fd7b74a	backend	GET	/api/permissions	200	14	2026-03-11T11:16:38.476Z
2ac24209-ed49-4add-81fe-81e054fb4065	backend	GET	/api/groups	200	17	2026-03-11T11:16:38.477Z
39c2b331-c5d6-4203-8638-a6a797999625	backend	GET	/api/groups/c696730a-7cdc-42dd-bcb7-a94c1e48662b/roles	200	9	2026-03-11T11:16:38.502Z
e987e51a-a69f-4491-b883-5e12d649f565	backend	GET	/api/groups/eb91551f-576d-4e15-aa46-84448578daa5/roles	200	9	2026-03-11T11:16:38.503Z
0d33237b-197e-4b69-8fc8-16a17e9b587c	backend	GET	/api/groups/1810f63c-0eea-489c-afaf-464b326b0512/roles	200	8	2026-03-11T11:16:38.504Z
5dfe2b71-abf6-4bcf-9e10-8301a3c74136	backend	GET	/api/groups/8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d/roles	200	7	2026-03-11T11:16:38.504Z
861e5e8d-53f5-4213-bfac-f07f119b924c	backend	GET	/api/groups/32b47175-b886-4f60-a78a-65a76fc00ec1/roles	200	12	2026-03-11T11:16:38.512Z
871cd49d-ac9d-49d7-a9c1-e77c8bda4676	backend	GET	/api/groups/09f744fb-0fe1-4868-8b85-a45118bc2c44/roles	200	16	2026-03-11T11:16:38.514Z
f2ecdb20-d4fb-4a54-868e-7f7b72fe7f64	backend	GET	/api/groups/e1cb962e-848b-4936-b9e7-d16a6b66a3f7/roles	200	5	2026-03-11T11:16:38.515Z
48702c3e-7a18-4529-97c2-efa1c976b98a	backend	GET	/api/groups/0a2d3acf-876d-423d-9e62-661850890abf/roles	200	16	2026-03-11T11:16:38.522Z
a685fd62-41c1-407a-8b7a-42aa3ac6358a	backend	GET	/api/groups/5f237b15-1bab-45c7-bb8c-3326a36b0003/roles	200	15	2026-03-11T11:16:38.523Z
f697c5fe-e748-4b4f-a3d5-3b862229ddb0	backend	GET	/api/groups/a4520de0-16f7-49d6-83ab-138372873a60/roles	200	14	2026-03-11T11:16:38.524Z
07f12fce-1e1a-4764-abba-6821daf64644	backend	GET	/api/users/2fef893c-6fd1-4929-92e7-b6af0cec4132/groups	200	7	2026-03-11T11:16:38.572Z
73ef405c-8123-4b7d-9bd4-3b51065cd0f2	backend	GET	/api/users/528c4843-72f8-413e-a09c-80167d54378b/groups	200	6	2026-03-11T11:16:38.572Z
2867c64f-04fc-4dac-8549-e08332da9c29	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd/groups	200	9	2026-03-11T11:16:38.573Z
4ac9ee35-6eb9-4192-af63-a49fd802eab6	backend	GET	/api/roles/1badaed8-e034-4fbc-9444-00dccf064485/permissions	200	4	2026-03-11T11:16:38.595Z
b946e033-78ab-4abe-8af7-b5655bd8d04f	backend	GET	/api/roles/5a9f8573-998f-4c4f-a13b-e68b205bf2a3/permissions	200	4	2026-03-11T11:16:38.595Z
a7b269f8-cade-45eb-a4f4-687bdd69b4ab	backend	GET	/api/roles/7f2d3793-85aa-41ea-b3c7-4422a915a86f/permissions	200	7	2026-03-11T11:16:38.596Z
2a801915-7a79-4e9f-a921-ab0360ed589e	ui	NAV	/users	200	6	2026-03-11T11:16:38.452Z
632134e0-9e28-42c8-82f6-7ebe5e40d75f	backend	POST	/api/auth/login	401	24	2026-03-11T11:45:11.122Z
b68d5a06-69c3-4edf-88bd-3e991263bde4	backend	POST	/api/auth/login	401	3	2026-03-11T11:45:46.023Z
19a4b267-d30a-448c-a398-4252c43a5f10	backend	POST	/api/auth/login	200	126	2026-03-11T11:46:40.791Z
c4277b84-8499-40e9-a6fc-8fc96e99407e	backend	GET	/api/auth/me	200	8	2026-03-11T11:46:45.050Z
03f51cf8-7f07-4e9c-b3fa-8718917bc409	backend	POST	/api/members	403	2	2026-03-11T11:46:49.345Z
e38cb6e8-d136-4c7f-99d9-1b8b8d2f2aed	backend	POST	/api/members	403	2	2026-03-11T11:46:54.304Z
56d9a9c6-b3cd-4a59-b532-236954a28c6b	backend	POST	/api/members	403	2	2026-03-11T11:47:06.960Z
ca882e78-b0a6-4807-8bb8-58fa1289192e	backend	POST	/api/members	200	12	2026-03-11T11:47:50.628Z
a6aa4de2-3c70-41bf-ad77-20ef46482281	backend	POST	/api/auth/refresh	200	13	2026-03-11T11:48:09.836Z
7268972f-d652-4dfc-9632-176b118d8d50	backend	POST	/api/auth/refresh	401	6	2026-03-11T11:48:16.597Z
d59583e5-79ca-4c95-b969-71340188469e	backend	POST	/api/auth/refresh	401	5	2026-03-11T11:48:21.102Z
5e6c7fab-1c0f-4473-9405-35fa370e2ae4	backend	POST	/api/auth/login	200	76	2026-03-11T11:48:29.323Z
089e0aeb-63c1-4e05-858b-5b1d437751b7	backend	POST	/api/auth/login	200	96	2026-03-11T11:54:07.309Z
2975392e-c764-4301-b13b-f2b9b844a351	backend	GET	/api/reports/dashboard-full	200	26	2026-03-11T11:54:07.353Z
fcc28f67-4ae6-4d71-aa7b-2582e8535508	ui	NAV	/login	200	326740	2026-03-11T11:40:09.965Z
40de6ae0-0649-44f5-9624-6ed3e9183761	ui	NAV	/	200	28	2026-03-11T11:54:07.350Z
ed48088a-da89-418f-b5b6-3c6bbdf38fd9	backend	GET	/api/departments/roles	200	18	2026-03-11T11:54:16.244Z
4565628c-395b-4627-ac24-bb0c7a42ea37	backend	GET	/api/departments/heads	200	20	2026-03-11T11:54:16.247Z
ceea1641-0b1f-41a5-840a-da2183b6a53a	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	28	2026-03-11T11:54:16.248Z
d52359ce-01f9-4f72-8f04-cdb115c1a244	backend	GET	/api/members?page=1&pageSize=500	200	29	2026-03-11T11:54:16.252Z
6cdfd5b0-e22c-472b-b453-ed56647705c2	backend	GET	/api/committees?page=1&pageSize=200	200	28	2026-03-11T11:54:16.253Z
a1eee92e-2bdb-4e03-a562-930b2e26176c	backend	GET	/api/departments?page=1&pageSize=200	200	32	2026-03-11T11:54:16.256Z
40f14604-d44a-4f28-8823-e1b13e930f65	backend	GET	/api/committees/chairs	200	10	2026-03-11T11:54:16.260Z
b71f01f5-729e-4d99-bbb7-cf6d8e4c4600	backend	GET	/api/members/pastors	200	8	2026-03-11T11:54:16.262Z
0ce1caf7-18f9-471c-92f8-7dcbc605bd99	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	8	2026-03-11T11:54:16.296Z
f5f8931b-6d1c-4e09-917f-e134347f3d98	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	14	2026-03-11T11:54:16.296Z
6e5e45a9-9400-4050-ae1a-dfbac253f80c	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	17	2026-03-11T11:54:16.303Z
a941a795-32f7-4f0d-aabd-53427e38c588	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	19	2026-03-11T11:54:16.303Z
47c6204d-2475-4740-9565-f091bcba96eb	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	17	2026-03-11T11:54:16.304Z
5013006d-1f7d-4095-9e52-aeb24d5408d5	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	17	2026-03-11T11:54:16.307Z
8f2d1d8a-c23f-4056-8563-8961246efce3	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	21	2026-03-11T11:54:16.320Z
2c7f9996-3247-4d49-aaed-d6af1fb35077	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	20	2026-03-11T11:54:16.321Z
9c4e0385-38b3-4d47-903f-6df370aaf379	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	14	2026-03-11T11:54:16.323Z
9f53c1f3-8e0c-4667-8c01-e1131f3d3a42	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	12	2026-03-11T11:54:16.325Z
a6ed9703-758f-42a0-baf9-8448b76312d9	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	6	2026-03-11T11:54:16.351Z
d33611dc-81ff-479e-8746-5d82953f1d6c	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	10	2026-03-11T11:54:16.352Z
53f10d0c-5edd-4704-a86f-abd93706548e	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	10	2026-03-11T11:54:16.353Z
28289a37-7c0b-40a4-8019-d617cd48a9ea	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	13	2026-03-11T11:54:16.354Z
bb83ec9e-210f-447a-9734-c2ddd26df433	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	9	2026-03-11T11:54:16.354Z
8e58f7b3-e07b-481e-8a80-30248c8ddf74	ui	NAV	/membership	200	10	2026-03-11T11:54:16.213Z
311837b1-1c58-43cc-aef9-761641b2b7b1	backend	GET	/api/branches/pastors	200	4	2026-03-11T11:54:25.669Z
b33c732d-4832-40e9-9e2d-da0524ed461f	backend	GET	/api/branches?page=1&pageSize=200	200	6	2026-03-11T11:54:25.670Z
ac8dccfe-87e3-4575-b1fe-83d3aea703da	ui	NAV	/branches	200	7	2026-03-11T11:54:25.660Z
62ee5553-7720-4504-8ac3-8b76854da141	backend	GET	/api/branches/pastors	200	4	2026-03-11T11:57:37.229Z
0fb9fba0-a791-47ef-8a3e-d15aaaea4984	backend	GET	/api/branches?page=1&pageSize=200	200	10	2026-03-11T11:57:37.233Z
07dd3db3-1a57-4458-a726-f908bdf707bf	backend	GET	/api/members?page=1&pageSize=500	200	8	2026-03-11T11:57:37.234Z
c5dc8ce6-73b7-4a16-a96d-5ba169b3c117	backend	GET	/api/auth/me	200	17	2026-03-11T12:01:08.746Z
f88afa47-1c87-40c9-80e8-c2e35ef09d50	backend	GET	/api/branches/pastors	200	20	2026-03-11T12:01:09.341Z
5f0149ec-7c9d-49ed-9344-a14466af07b0	backend	GET	/api/branches?page=1&pageSize=200	200	23	2026-03-11T12:01:09.342Z
dec49395-73fc-40e4-869d-b27ff730827a	backend	GET	/api/members?page=1&pageSize=500	200	21	2026-03-11T12:01:09.343Z
6e718978-0c01-4a30-aee1-35838a32b84c	ui	NAV	/branches	200	18	2026-03-11T12:01:08.677Z
1a47dde8-3969-4a57-adf1-2eabf3d868bf	ui	NAV	/branches	200	25	2026-03-11T12:01:29.450Z
3957a956-a058-47f5-b444-17d61b9e747e	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	21	2026-03-11T12:01:44.857Z
58ed9fc3-4a90-40bf-a4fa-3865576e0bd8	backend	GET	/api/members?page=1&pageSize=500	200	22	2026-03-11T12:01:44.857Z
7a1ba78c-c0e9-4bc6-9e82-701d7a28544f	backend	GET	/api/departments/roles	200	18	2026-03-11T12:01:44.860Z
96449173-abfe-4c81-ab20-f171d039074a	backend	GET	/api/committees?page=1&pageSize=200	200	25	2026-03-11T12:01:44.865Z
7a97d442-2681-4176-a179-3e8c61698a9e	backend	GET	/api/departments?page=1&pageSize=200	200	34	2026-03-11T12:01:44.873Z
820535b4-6e8f-4e09-aa6a-eddf9df5722a	backend	GET	/api/departments/heads	200	31	2026-03-11T12:01:44.875Z
984a9c14-b4ad-4e64-bb93-097559ae86ef	backend	GET	/api/members/pastors	200	14	2026-03-11T12:01:44.878Z
5c042677-1930-4478-8e21-f327a72f7ef4	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	9	2026-03-11T12:01:44.897Z
52fae056-476e-4da9-b9e8-706f930cf21a	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	8	2026-03-11T12:01:44.908Z
5ea16ba7-33c2-4136-8969-1d30df9493d2	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	9	2026-03-11T12:01:44.914Z
8f998955-061d-4bcb-9c16-cd58ff1fcbd5	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	11	2026-03-11T12:01:44.933Z
59689dec-f2c9-497b-a5d3-dfd599ca8a39	backend	GET	/api/branches?page=1&pageSize=200	200	7	2026-03-11T12:01:59.471Z
5923d236-4cdc-4da0-b3aa-db6abbbe84e7	backend	GET	/api/branches/69047316-0c00-42cd-99ba-af436d211b59	200	4	2026-03-11T12:02:02.854Z
235c7e38-cb4c-469f-adbe-c40f47e86c80	ui	NAV	/branches	200	12	2026-03-11T12:01:59.467Z
60caa7f9-9a5d-4042-b373-bfb878eb6267	backend	GET	/api/roles	200	6	2026-03-11T12:02:32.008Z
b96baf0d-b4d2-40ea-b5f3-5ccd555c8c67	backend	GET	/api/groups	200	10	2026-03-11T12:02:32.010Z
2cbdcaaf-ae12-4243-99a4-d4deaa6a4cbf	backend	GET	/api/groups/c696730a-7cdc-42dd-bcb7-a94c1e48662b/roles	200	6	2026-03-11T12:02:32.031Z
12a32a9d-04b0-4275-bf4c-c7869c921087	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	9	2026-03-11T12:02:52.892Z
9d2c4db7-cbdb-4bf7-8a63-2800c8d11922	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	8	2026-03-11T12:02:52.893Z
1d409ad4-f734-4205-aa81-b7238289bf51	ui	NAV	/membership	200	10	2026-03-11T12:02:52.824Z
23002b31-d9a4-468a-9cf2-0cdbf23190e1	backend	GET	/api/sms?page=1&pageSize=50	200	4	2026-03-11T12:02:58.035Z
337200f1-586d-487e-a048-a43d93ff6e47	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	12	2026-03-11T12:01:44.902Z
f4cab519-b0db-44a5-b2f2-00e5d89a7695	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	9	2026-03-11T12:01:44.903Z
a325a65a-4238-440c-a549-9a0d916f5f90	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	12	2026-03-11T12:01:44.907Z
c495ebec-9bed-434a-b71a-38bf7e6a7c71	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	6	2026-03-11T12:01:44.916Z
ecec619f-f1e4-48a2-bced-c741c337b4de	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	11	2026-03-11T12:01:44.934Z
fb7e7a27-e858-42e0-b5ef-62631486b405	backend	GET	/api/groups/09f744fb-0fe1-4868-8b85-a45118bc2c44/roles	200	6	2026-03-11T12:02:32.045Z
04096c80-0f9e-40d0-8630-cb346e4efe7c	backend	GET	/api/groups/a4520de0-16f7-49d6-83ab-138372873a60/roles	200	6	2026-03-11T12:02:32.053Z
a1e64490-b41a-4675-b7dd-d2fa863a0f9c	backend	GET	/api/users/5365cc82-1f96-4b9f-91b1-2476bc2e3a4a/groups	200	7	2026-03-11T12:02:32.068Z
0953de47-cfb2-4fbb-964d-6999a0efed61	backend	GET	/api/committees?page=1&pageSize=200	200	8	2026-03-11T12:02:52.838Z
50d81a81-7dcc-4d1b-ba6e-83d1076f4c26	backend	GET	/api/members/pastors	200	4	2026-03-11T12:02:52.846Z
36a67c3d-333e-4424-8269-589c19caed44	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	11	2026-03-11T12:02:52.866Z
037d91ac-4f23-4591-a8cf-4ea88cf04e33	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	8	2026-03-11T12:02:52.867Z
d1654756-0544-400f-a4f7-d745af35bcd0	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	7	2026-03-11T12:02:52.872Z
d005b52e-059d-4b35-ae8d-98475a2842b4	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	4	2026-03-11T12:02:52.892Z
5bba5750-7614-49ab-8131-ec9ad875eabc	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	12	2026-03-11T12:01:44.904Z
93840be7-2840-4fae-ac55-818846c74c72	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	16	2026-03-11T12:01:44.908Z
ca101bd2-9c09-4310-b2d1-7b456129cac7	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	5	2026-03-11T12:01:44.914Z
9e9d92c9-c09e-426a-8d40-d388a3a86fe4	backend	GET	/api/groups/8e5111bb-c4ad-487d-a2b2-6ee1f3c1648d/roles	200	8	2026-03-11T12:02:32.041Z
aa553b7e-ccfd-4b69-8224-4b0f4f17d83e	backend	GET	/api/groups/0a2d3acf-876d-423d-9e62-661850890abf/roles	200	5	2026-03-11T12:02:32.043Z
5794401c-ddbe-453c-9557-20da26d5fe23	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd/groups	200	6	2026-03-11T12:02:32.068Z
b15e2f04-f44f-4181-bf02-efa6f532b638	backend	GET	/api/roles/1badaed8-e034-4fbc-9444-00dccf064485/permissions	200	4	2026-03-11T12:02:32.082Z
48a6961c-cdb1-4ef3-8619-429e7b0c1245	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	12	2026-03-11T12:02:52.835Z
e7442e84-184a-48a0-a2d8-72635b297a1b	backend	GET	/api/committees/chairs	200	5	2026-03-11T12:02:52.846Z
8f615257-4281-4721-aebd-2fa0432ce2cd	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	4	2026-03-11T12:02:52.891Z
abca194c-f070-404a-ad2a-dc7475539901	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	7	2026-03-11T12:02:52.893Z
c15ffe56-0c97-403d-a7e8-5f94019fe1d0	backend	GET	/api/members/293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	200	6	2026-03-11T12:02:58.036Z
4f53b4a5-4654-49ec-b653-26f7ade39b09	ui	NAV	/membership/member/293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	200	4	2026-03-11T12:02:58.019Z
b11fd64f-b5ab-495f-8f26-56808800d44a	ui	NAV	/membership	200	17	2026-03-11T12:03:01.084Z
35b0e63c-b3ce-4f16-bebc-d9e76cac3e1f	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	5	2026-03-11T12:01:44.930Z
505caaac-fb70-4c44-868f-24fd1e753897	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	7	2026-03-11T12:01:44.933Z
a7ed6118-8567-448c-b8f3-056d17650e54	backend	GET	/api/users?page=1&pageSize=500	200	9	2026-03-11T12:02:32.007Z
d81f818b-c17c-46d4-a93d-4bc43f3b36c1	backend	GET	/api/permissions	200	7	2026-03-11T12:02:32.011Z
0ecbfcda-1b3f-4100-a441-72f1caf8cfaf	backend	GET	/api/groups/eb91551f-576d-4e15-aa46-84448578daa5/roles	200	5	2026-03-11T12:02:32.031Z
9b971efa-09a0-421e-baac-267e87791795	backend	GET	/api/groups/1810f63c-0eea-489c-afaf-464b326b0512/roles	200	8	2026-03-11T12:02:32.044Z
edb6c8e8-0a67-49ab-b93d-1286a2f3c535	backend	GET	/api/users/2fef893c-6fd1-4929-92e7-b6af0cec4132/groups	200	5	2026-03-11T12:02:32.069Z
dcd28da7-a102-4709-91d8-9cfce0b9fe63	backend	GET	/api/roles/5a9f8573-998f-4c4f-a13b-e68b205bf2a3/permissions	200	3	2026-03-11T12:02:32.083Z
cdeacf6e-16a7-4c5f-b0ca-ed93a329560f	ui	NAV	/users	200	14	2026-03-11T12:02:32.000Z
632d755f-d38f-4144-849e-da09c68e92f0	backend	GET	/api/departments/roles	200	4	2026-03-11T12:02:52.837Z
c51bf6d1-4c10-4e99-b9cf-3544e3898bc0	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	8	2026-03-11T12:02:52.862Z
783d52d2-0583-4d8f-bd45-c56929ea5a55	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	5	2026-03-11T12:02:52.863Z
3fb96b22-e565-4e64-8d33-dd5ff557995f	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	10	2026-03-11T12:02:52.866Z
3597737b-cb75-4aad-8ca6-5598622417a2	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	5	2026-03-11T12:02:52.878Z
b227ac91-d357-4be6-bcfe-0adfcb8bca6c	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	9	2026-03-11T12:01:44.934Z
fd8105d8-1d8c-44cd-bc4f-3ce66b00338f	ui	NAV	/membership	200	5	2026-03-11T12:01:44.753Z
1b3ccbb8-e671-433f-9d9f-1c666ea0dc3f	backend	GET	/api/branches/pastors	200	5	2026-03-11T12:01:59.469Z
6addf344-9014-4c23-b5e7-327fa553a3a7	backend	GET	/api/members?page=1&pageSize=500	200	11	2026-03-11T12:02:52.836Z
a56d06a5-dc86-410c-98b1-1c88d7a146d4	backend	GET	/api/departments?page=1&pageSize=200	200	10	2026-03-11T12:02:52.838Z
abe00a80-72e8-46b0-915c-52a926f813fe	backend	GET	/api/departments/heads	200	7	2026-03-11T12:02:52.841Z
bb77f180-5d99-4d98-88ab-8db8cdca8f5f	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	9	2026-03-11T12:02:52.867Z
56bc392e-82c4-4df4-9d53-9851c9443545	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	7	2026-03-11T12:02:52.875Z
d49c39d4-7f93-4fad-bc0c-03c0a24cfa26	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	4	2026-03-11T12:02:52.879Z
1d028db3-bdee-476c-8ec9-ecc3763f4803	backend	GET	/api/groups/32b47175-b886-4f60-a78a-65a76fc00ec1/roles	200	5	2026-03-11T12:02:32.043Z
5e34c930-4bc8-44f3-9ad3-44088e9e3c00	backend	GET	/api/groups/5f237b15-1bab-45c7-bb8c-3326a36b0003/roles	200	5	2026-03-11T12:02:32.045Z
40b29919-e4b3-4c01-b98c-5471e2377562	backend	GET	/api/groups/e1cb962e-848b-4936-b9e7-d16a6b66a3f7/roles	200	3	2026-03-11T12:02:32.052Z
fabaf57f-95c9-4d86-bc0d-96631c6f6098	backend	GET	/api/users/528c4843-72f8-413e-a09c-80167d54378b/groups	200	4	2026-03-11T12:02:32.069Z
2559f6ba-3d1b-4dd5-8a16-4d85be5ad3eb	backend	GET	/api/roles/7f2d3793-85aa-41ea-b3c7-4422a915a86f/permissions	200	6	2026-03-11T12:02:32.083Z
5c458a71-d23b-4a8c-9efd-cf0fe7ca7d20	backend	GET	/api/reports/summary	200	8	2026-03-11T12:02:46.404Z
5f6ea934-8bff-44fd-bdab-41fb3eaac0a2	backend	GET	/api/users/dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	200	3	2026-03-11T12:02:47.779Z
6b99dd19-110e-4008-978f-2bd1d2be7638	backend	GET	/api/reports/dashboard-full	200	9	2026-03-11T12:02:49.824Z
9d4c36fd-2ef4-45d8-a9e3-830226ee88f5	ui	NAV	/reports	200	15	2026-03-11T12:02:46.400Z
95a03bcb-be88-4ce0-929a-4f2ed39eb208	ui	NAV	/profile	200	23	2026-03-11T12:02:47.789Z
ea533796-0e35-4369-bc1b-337139c6394b	ui	NAV	/	200	9	2026-03-11T12:02:49.815Z
e199a98b-b463-40ee-a75c-c216d147b2fb	backend	GET	/api/members/pastors	200	68	2026-03-11T12:08:21.397Z
284670b4-a702-412c-a760-babc015ccff6	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	81	2026-03-11T12:08:21.399Z
a5f41179-7042-4533-967c-50cdeedf8979	backend	GET	/api/committees/chairs	200	82	2026-03-11T12:08:21.407Z
39232ea1-fe57-401d-859c-6d55588d8b8c	backend	GET	/api/departments?page=1&pageSize=200	200	81	2026-03-11T12:08:21.409Z
695890b5-8e94-4475-a224-c274aaab7b70	backend	GET	/api/members?page=1&pageSize=500	200	89	2026-03-11T12:08:21.413Z
b97bed96-5014-4f73-92b2-436249e2e098	backend	GET	/api/committees?page=1&pageSize=200	200	83	2026-03-11T12:08:21.414Z
2c21a30e-47cb-4dbe-a01c-35e5a346394d	backend	GET	/api/departments/roles	200	11	2026-03-11T12:08:21.422Z
aadf41e5-27fe-4175-8e73-3a6c52e95865	backend	GET	/api/departments/heads	200	17	2026-03-11T12:08:21.429Z
123f4fb7-406d-4063-aef9-f012ed321eca	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	19	2026-03-11T12:08:21.468Z
df956a3b-58d2-4ae8-ad00-e98533e001d6	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	15	2026-03-11T12:08:21.473Z
71484b4e-bd8a-4355-a190-d5b1b3701a65	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	23	2026-03-11T12:08:21.476Z
da0c83af-3c59-4f30-8962-c7381699917d	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	22	2026-03-11T12:08:21.477Z
2f92a4ae-c425-4a40-b166-ce1effb48882	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	21	2026-03-11T12:08:21.478Z
9cf338fd-e212-48b8-ac01-ee896f4fe36a	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	29	2026-03-11T12:08:21.488Z
a15f0de9-61d7-4995-b43a-124774d7b644	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	15	2026-03-11T12:08:21.489Z
4eab890f-d5d7-4225-bfa4-fe176aa8db4e	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	12	2026-03-11T12:08:21.493Z
05796e64-19a3-49ce-807f-99aca2332488	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	14	2026-03-11T12:08:21.494Z
8a94851d-88ec-41e3-8317-e5760a04b2dc	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	9	2026-03-11T12:08:21.496Z
bcff8f20-b10e-43f0-8234-5db1b7f8dcf7	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	10	2026-03-11T12:08:21.522Z
4dfeac8e-ee39-4d24-afe1-ed2fda333bbe	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	18	2026-03-11T12:08:21.523Z
e70ebfd9-243d-4394-97fb-7e05e02d4acd	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	13	2026-03-11T12:08:21.524Z
376ecf87-db7a-4cee-90e9-00e4ef874087	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	15	2026-03-11T12:08:21.525Z
af7a79c7-9883-4138-8fe0-efa933f88c42	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	18	2026-03-11T12:08:21.532Z
d1e7e7b1-1911-4527-9db0-e9a502182d86	backend	GET	/api/departments/roles	200	5	2026-03-11T12:09:41.257Z
5f418cc8-4035-4a87-849f-cb6c18a37faf	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	23	2026-03-11T12:09:41.270Z
65395844-7836-479f-97c3-a6eb162652bc	backend	GET	/api/departments/heads	200	19	2026-03-11T12:09:41.272Z
40d173e1-7123-459c-89db-1ef984be8622	backend	GET	/api/departments?page=1&pageSize=200	200	24	2026-03-11T12:09:41.275Z
836526a6-991f-4348-9ddb-f3b556bf4380	backend	GET	/api/members?page=1&pageSize=500	200	6	2026-03-11T12:09:41.298Z
bc16674c-33f7-4bb6-b521-c7ec70c95e53	backend	GET	/api/committees?page=1&pageSize=200	200	4	2026-03-11T12:09:41.307Z
4178b7ad-e79d-44f3-b1b3-96944ccec1f4	backend	GET	/api/committees/chairs	200	10	2026-03-11T12:09:41.322Z
3be944fe-c8b8-4aa9-8837-80c60b59ceb9	backend	GET	/api/members/pastors	200	4	2026-03-11T12:09:41.331Z
3d262b8b-02f0-42e7-9128-7e2cb5a04279	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	17	2026-03-11T12:09:41.354Z
fabecfab-7417-403d-8220-758a24886b15	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	7	2026-03-11T12:09:41.356Z
c7709be4-2d80-4adf-aba8-24716cfd012c	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	21	2026-03-11T12:09:41.360Z
8148d4c1-3e2e-46c0-99cb-7c2feaef40df	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	21	2026-03-11T12:09:41.360Z
66767af6-5efa-4161-a819-f72f86f40efc	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	18	2026-03-11T12:09:41.361Z
c8fdcd95-9f22-4d3e-bf1a-07707b28d950	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	15	2026-03-11T12:09:41.365Z
4b55fa96-1ece-4634-9f7c-f984290c9767	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	12	2026-03-11T12:09:41.370Z
e402aa39-baeb-4720-8b93-ac91e1cbcbf1	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	10	2026-03-11T12:09:41.372Z
4e189178-3e78-43b1-b9b4-088812c2ebf2	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	9	2026-03-11T12:09:41.374Z
74c38d89-4389-44aa-be30-27803d64cf58	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	7	2026-03-11T12:09:41.375Z
5666d8ce-4f97-4b5d-9b25-7cbfdb6535fb	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	4	2026-03-11T12:09:41.392Z
44ba8370-fdf0-42b7-984d-0fafdab1e510	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	10	2026-03-11T12:09:41.394Z
f327743e-a35f-4c17-a8ce-31101d90d5e5	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	8	2026-03-11T12:10:16.450Z
14fbb05a-3f07-4aa2-87b4-d9beaf92962f	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	6	2026-03-11T12:09:41.395Z
b014e212-1886-4d23-8e11-90bfcf0bf56a	backend	GET	/api/members?page=1&pageSize=500	200	6	2026-03-11T12:10:16.323Z
3eea8f15-702b-4aa5-b7ba-a8a3978c9e28	backend	GET	/api/committees?page=1&pageSize=200	200	20	2026-03-11T12:10:16.348Z
c3dac16d-e07e-409f-a0b7-b2ef8e304478	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	15	2026-03-11T12:10:16.403Z
d455953f-749b-45e0-b699-dd746868f534	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	17	2026-03-11T12:10:16.407Z
8a4230db-2f3c-4cf2-9728-56c0497f7125	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	12	2026-03-11T12:10:16.408Z
f20304ac-80f2-437c-8370-e022913cce8a	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	24	2026-03-11T12:10:16.425Z
cfc92e7c-5ffa-49ea-9fe5-c56ec4201361	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	19	2026-03-11T12:10:16.428Z
a485e1ab-b4d7-4d7e-99c0-52db61361d25	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	16	2026-03-11T12:10:16.431Z
3fefb1a5-f9d0-44e7-971a-943cef0438de	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	13	2026-03-11T12:10:16.432Z
9b298c6c-664d-4155-9bd7-deef9b044af4	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	13	2026-03-11T12:10:16.434Z
7f0cf8b3-d572-4dd6-b693-bf87d6806d4a	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	8	2026-03-11T12:10:16.451Z
d6bffaaa-6c99-4bb2-9bb1-1f478403277e	backend	GET	/api/permissions	403	37	2026-03-11T13:16:07.955Z
2e9f0b27-2f48-4f1c-a77d-38b551fca8e7	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	9	2026-03-11T12:09:41.396Z
85b596c2-4db6-41eb-95b7-2a165d9b2e07	backend	GET	/api/departments/roles	200	14	2026-03-11T12:10:16.291Z
feef6d5a-d74a-42ff-8036-face8aae5326	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	33	2026-03-11T12:10:16.298Z
bafe479e-c62e-480b-9513-cbb18b399e88	backend	GET	/api/departments?page=1&pageSize=200	200	42	2026-03-11T12:10:16.308Z
eb0cede1-dfb2-4595-9915-726078d55b3c	backend	GET	/api/departments/heads	200	26	2026-03-11T12:10:16.311Z
aa2c0c15-cd99-45e1-b188-c10ad7223d6c	backend	GET	/api/committees/chairs	200	7	2026-03-11T12:10:16.372Z
1773ed29-37a2-468b-ba3e-04c0848cca09	backend	GET	/api/members/pastors	200	4	2026-03-11T12:10:16.383Z
31d49765-8f76-4ee6-b88c-d233c9d6038f	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	16	2026-03-11T12:10:16.408Z
e90ab502-b791-47db-be32-2ee9eb1fa394	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	21	2026-03-11T12:10:16.414Z
61575c28-005e-4f38-ba5a-b559e91d5dcc	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	5	2026-03-11T12:10:16.449Z
6f94994f-e676-40fd-979c-d7fb2621cec9	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	10	2026-03-11T12:10:16.450Z
0c740c7b-b0b8-4637-b3f4-8e7ac57a5173	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	6	2026-03-11T12:10:16.451Z
a4b26b1b-8b11-456e-8e75-922e231b05ba	backend	GET	/api/groups	403	42	2026-03-11T13:16:07.957Z
219197f2-0991-41a4-977d-e8b690e5b248	backend	GET	/api/members?page=1&pageSize=300	403	4	2026-03-11T13:16:11.854Z
30ab6b6f-35e2-4ab9-854a-1ae97e9112b3	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	15	2026-03-11T12:28:05.243Z
5617edbf-d2d8-4f9f-bf59-0bb14bb23178	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	12	2026-03-11T12:28:05.322Z
544f5fc2-7e4a-4039-a127-8c13983e0fa7	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	5	2026-03-11T12:28:05.351Z
6bf3deee-a65a-4f88-95e0-966c847a5e79	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	9	2026-03-11T12:28:05.353Z
119d97cb-917d-408f-acf3-15e15ab05223	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	49	2026-03-11T12:32:51.346Z
c8fb0a81-7952-421e-8e40-76cf7a7e21df	backend	GET	/api/departments/roles	200	50	2026-03-11T12:32:51.360Z
1745d6bb-9453-4f9f-aede-7e1f52f47e21	backend	GET	/api/departments?page=1&pageSize=200	200	73	2026-03-11T12:32:51.375Z
cf181f52-e327-4fbe-8465-b9efffc928d7	backend	GET	/api/departments/heads	200	39	2026-03-11T12:32:51.386Z
a451eac4-b90c-4190-a7b4-f0c94ce30f58	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	26	2026-03-11T12:32:51.648Z
c60a643d-a7c9-4c41-a2be-7ead515b35b5	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	6	2026-03-11T12:32:51.687Z
bf4faf93-b72e-496d-8aa8-219737d93ff6	backend	GET	/api/roles	403	50	2026-03-11T13:16:07.969Z
21ab4179-cdea-4326-a1f2-0f2c7de28cf8	backend	GET	/api/members?page=1&pageSize=500	403	3	2026-03-11T13:16:10.266Z
4b65b17d-0a30-4135-a471-d5965a856c7f	backend	GET	/api/branches/pastors	403	3	2026-03-11T13:16:10.272Z
aea945be-9ed1-4c72-8611-889f2c12e3ab	backend	GET	/api/sms/templates	403	4	2026-03-11T13:16:11.851Z
9e73891b-963c-4d3a-8e35-93f79aefd805	backend	GET	/api/departments/heads	200	17	2026-03-11T12:28:05.247Z
85f02136-a3e8-4076-8815-73654480de10	backend	GET	/api/departments/roles	200	22	2026-03-11T12:28:05.251Z
5eb39a71-f523-48a1-b6a6-914d671c3f78	backend	GET	/api/departments?page=1&pageSize=200	200	24	2026-03-11T12:28:05.253Z
1ea99cb0-0b2d-4ff9-b085-2d49f0eb73ac	backend	GET	/api/members?page=1&pageSize=500	200	4	2026-03-11T12:28:05.262Z
f743158d-395f-48b6-b53a-42bbe062efba	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	9	2026-03-11T12:28:05.323Z
3f001a3a-16c1-4479-8eb9-8682010eb24e	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	8	2026-03-11T12:28:05.327Z
895fbcbf-bf09-4f0e-afc9-613a029a1a8e	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	4	2026-03-11T12:28:05.332Z
e968676d-cfea-4548-a669-97b9163ddf14	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	7	2026-03-11T12:28:05.333Z
fde2217a-482c-4580-a4b8-d9e0a0521309	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	11	2026-03-11T12:28:05.354Z
ab34a4af-8f93-48d8-bbbc-532a0fc32249	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	10	2026-03-11T12:32:51.688Z
9f61506a-2fc2-4037-8c7d-0dc74bce843d	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	8	2026-03-11T12:32:51.692Z
33928765-bbb6-4b3a-b078-3eaf75a5b542	ui	NAV	/membership	200	26	2026-03-11T12:32:51.156Z
6a3cc758-0c39-4dd6-a5ce-a2725988be7c	backend	GET	/api/branches?page=1&pageSize=200	403	3	2026-03-11T13:16:10.271Z
8a47686f-e53b-47b6-8227-81645ada0b4f	backend	GET	/api/sms?page=1&pageSize=20	403	3	2026-03-11T13:16:11.852Z
1cf42fc5-89cf-47ae-ad4e-fee746ffabca	backend	GET	/api/committees?page=1&pageSize=200	200	3	2026-03-11T12:28:05.270Z
3920fa0f-da12-4976-bd6c-a327f7c81b97	backend	GET	/api/committees/chairs	200	4	2026-03-11T12:28:05.281Z
dc81151e-43e6-4c1c-bf6d-44ae739962d2	backend	GET	/api/members/pastors	200	3	2026-03-11T12:28:05.290Z
9c3b9be9-18fb-455c-88a1-8936854989ba	backend	POST	/api/sms/balance	403	8	2026-03-11T13:16:11.853Z
c1e9ea23-27de-417b-883c-66e3dfe16c42	ui	NAV	/users	200	7	2026-03-11T13:16:07.884Z
62a423d3-b0da-4b0a-92f4-c6b708296cec	ui	NAV	/branches	200	6	2026-03-11T13:16:10.259Z
5185d20b-b8a7-46f1-b075-7a01528d8315	ui	NAV	/sms	200	13	2026-03-11T13:16:11.842Z
49c0a7e8-0e6e-4783-8bd5-324a68c786d7	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	9	2026-03-11T12:28:05.315Z
abec8647-85fa-4172-a95e-c2b9435762fc	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	11	2026-03-11T12:32:51.632Z
e28f64f4-96ea-4244-a8c1-4768b277c90b	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	21	2026-03-11T12:32:51.649Z
9b9d1845-e466-4a5b-9222-c1fbeffbbe7c	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	8	2026-03-11T12:32:51.688Z
bb935ff5-471a-4780-9417-705ec33feec5	backend	POST	/api/auth/login	403	162	2026-03-11T15:05:08.917Z
5623c194-5440-4606-bf6e-9dcd657a511b	backend	POST	/api/auth/login	403	91	2026-03-11T15:05:13.354Z
890feec3-941a-427d-ada3-3137b7d5791b	backend	POST	/api/auth/login	403	85	2026-03-11T15:05:16.923Z
230b8f74-50b5-4b44-b04b-973ad70b829f	backend	GET	/api/auth/me	401	1	2026-03-11T15:07:29.636Z
0cdcaba8-46f6-4c26-a6bf-f265d6c95765	backend	POST	/api/auth/refresh	200	46	2026-03-11T15:07:29.717Z
b7146772-54d8-4a06-a66c-5028795c359b	backend	GET	/api/auth/me	200	24	2026-03-11T15:07:29.817Z
e5d87af3-3745-4412-a03e-525a41424200	ui	NAV	/login	200	188	2026-03-11T15:07:29.769Z
46ce620c-629f-481f-8927-fb35cdfb48cf	backend	POST	/api/auth/login	403	74	2026-03-11T15:07:37.124Z
7da85145-579a-47f4-ad0a-a8c5d776d358	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	9	2026-03-11T12:28:05.316Z
22b91f82-7360-4b62-b811-ab8586ab09a0	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	9	2026-03-11T12:28:05.321Z
b467c151-d2bb-4c61-a7ad-d71e24b58b8a	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	6	2026-03-11T12:28:05.323Z
6b6c621a-f5f1-4a9e-ae65-e62a360cf34f	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	6	2026-03-11T12:28:05.353Z
e796a0a8-0067-42a3-afeb-b8b165ddf42b	backend	GET	/api/auth/me	200	19	2026-03-11T12:32:51.159Z
10c2bcf2-1a4a-4ffa-a341-201432d10085	backend	GET	/api/members?page=1&pageSize=500	200	62	2026-03-11T12:32:51.506Z
74ac87cd-2b29-4cfe-b766-d0bd1268bbcb	backend	GET	/api/committees?page=1&pageSize=200	200	5	2026-03-11T12:32:51.570Z
82bfdb06-d096-4b15-8b9b-5ef0a5380765	backend	GET	/api/committees/chairs	200	6	2026-03-11T12:32:51.585Z
ec7357fa-4094-4b3f-afce-ddac595e4945	backend	GET	/api/members/pastors	200	21	2026-03-11T12:32:51.613Z
5cc18a34-4716-455a-9326-b75347a5f028	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	24	2026-03-11T12:32:51.650Z
0e5e14d3-e9f9-4b56-9795-7fc31aeb5b06	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	14	2026-03-11T12:32:51.664Z
3ed887d3-8e49-4ffb-80bb-053399ff85d0	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	8	2026-03-11T12:32:51.668Z
d7018178-5f59-45bb-b196-67eac9255698	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	11	2026-03-11T12:32:51.688Z
bfa17bc3-7a17-4987-8155-32bdf151c0d7	backend	POST	/api/auth/login	200	128	2026-03-11T15:10:29.294Z
8f60aa47-813b-4548-933b-ae37dd321d63	backend	GET	/api/groups	200	9	2026-03-11T15:10:33.567Z
334e043f-0083-4a86-8150-33fbb4b2b2a5	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	13	2026-03-11T12:28:05.322Z
bd5fc688-599a-426b-98a2-980a91987387	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	10	2026-03-11T12:28:05.355Z
cea7aa67-0275-4729-a889-3698ccae6ad0	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	26	2026-03-11T12:32:51.650Z
4fa60eb3-4556-4d50-95e1-d647c026cc99	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	29	2026-03-11T12:32:51.659Z
8d4c329b-c85e-4e50-b33c-234e29cd4667	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	11	2026-03-11T12:32:51.668Z
dab29dfe-227b-4b34-8364-03b6bb555fc4	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	7	2026-03-11T12:32:51.670Z
f75aac2d-f136-41c9-9f1f-e31f60d32bbb	backend	POST	/api/auth/login	200	123	2026-03-11T15:11:23.252Z
1cfa6f30-c2f5-4d2d-ae93-231dc1c2c529	backend	GET	/api/groups	200	6	2026-03-11T15:11:28.965Z
ecdf5899-813c-4172-85b9-6a9b38f41e11	backend	POST	/api/users	400	8	2026-03-11T15:11:35.014Z
c23ef04c-2c3e-4c7c-adce-82ae816116d3	backend	GET	/api/auth/me	200	59	2026-03-11T12:57:01.577Z
4c5efffa-057f-4654-8f3a-9d75ed32ee15	backend	GET	/api/departments?page=1&pageSize=200	200	25	2026-03-11T12:57:01.792Z
fb0764f6-41eb-4346-9090-a1c0afc8b70a	backend	GET	/api/departments/roles	200	8	2026-03-11T12:57:01.806Z
bd732170-3f7b-4995-9dfa-8a09cef16c8d	backend	GET	/api/departments/heads	200	24	2026-03-11T12:57:01.825Z
899dc6c3-7a15-4ea0-ab02-68a488f05b13	backend	GET	/api/members?page=1&pageSize=500	200	17	2026-03-11T12:57:01.858Z
50881674-17ca-4f9f-9132-84c4f456b4b8	backend	GET	/api/committees/chairs	200	5	2026-03-11T12:57:01.896Z
1105392b-4bad-495f-ab2d-05e8d67f527b	backend	GET	/api/members/pastors	200	4	2026-03-11T12:57:01.908Z
f77a06d9-abd2-4db3-9f89-1dafb2e1a149	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	23	2026-03-11T12:57:01.949Z
1c7e7aa9-a27e-4b42-8287-5ceb2e3bdcd8	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	29	2026-03-11T12:57:01.973Z
2f19a888-c3f6-4503-bd3d-4be2fbcdb120	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	13	2026-03-11T12:57:01.980Z
b00713c8-77f3-4d94-b822-14611317ed68	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	10	2026-03-11T12:57:02.011Z
419f0553-8305-4e45-a86e-1967099c9d2f	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	16	2026-03-11T12:57:02.014Z
69cf62ce-18f2-4dbb-ae93-07de7e5d9533	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	16	2026-03-11T12:57:02.015Z
39543022-e2f1-4194-9ca4-d9cde645cd99	backend	POST	/api/users	200	119	2026-03-11T15:11:40.610Z
ffd8993a-304b-4224-972d-c0629db3ac60	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	44	2026-03-11T12:57:01.791Z
51057341-882b-4ca7-b9a9-1dd7b58ea619	backend	GET	/api/committees?page=1&pageSize=200	200	9	2026-03-11T12:57:01.880Z
b2cba68f-85a6-4a5d-b714-c127422eb6bb	backend	POST	/api/auth/login	200	117	2026-03-11T15:12:31.768Z
e17b0e29-8bad-47c3-82fa-f59548c30ef4	backend	POST	/api/auth/login	403	88	2026-03-11T15:12:37.042Z
6b840738-1c2f-40ac-8020-0b3b3e4217d0	backend	GET	/api/groups	200	7	2026-03-11T15:13:24.890Z
62d4aa81-9ce5-4440-9616-2ee6649c4367	backend	POST	/api/groups	200	8	2026-03-11T15:13:33.294Z
99b2aa33-d8a7-457a-8030-65e8869f6408	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	24	2026-03-11T12:57:01.941Z
7df6f0e2-10bd-4262-b103-4045f15f5253	backend	POST	/api/groups	200	16	2026-03-11T15:13:33.298Z
5fe918e5-69e8-4a88-ad45-3b52e8391cec	backend	POST	/api/users	200	98	2026-03-11T15:13:39.687Z
999e565b-0e10-43ef-ad88-bc2d820e6c5e	backend	POST	/api/users	200	103	2026-03-11T15:13:50.953Z
0f59a84a-a6de-4d62-bac6-1db8ddbe7125	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	38	2026-03-11T12:57:01.959Z
0d168961-073f-4ec8-afcc-f3dc73162e1e	backend	GET	/api/departments/heads	200	20	2026-03-11T15:13:43.534Z
0ee9e625-2d1f-4dac-89c9-f6fc5d691612	backend	POST	/api/auth/login	200	113	2026-03-11T15:13:55.207Z
2fa4bc96-a724-4504-8574-c9c3de4a2510	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	38	2026-03-11T12:57:01.960Z
181b6b89-47d4-47a9-b5e5-4d5d2d0eede1	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	43	2026-03-11T12:57:01.962Z
ee353788-dc11-4cc7-9fd1-a5bff81c1602	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	15	2026-03-11T12:57:01.969Z
10cf7e37-366b-4716-9627-3b04154ac83d	backend	GET	/api/departments	200	10	2026-03-11T15:15:15.991Z
1bf9f670-2734-4d26-9be2-a422c72983dc	backend	GET	/api/users	403	4	2026-03-11T15:15:39.544Z
f4ee90dc-5dc6-4883-9797-56b2c1dc6b47	backend	POST	/api/users	400	5	2026-03-11T15:16:55.726Z
933ded2d-78e1-4d2e-883c-01bf0f80055b	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	34	2026-03-11T12:57:01.970Z
fe18be2f-d457-4c0e-91a2-402304f1030d	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	13	2026-03-11T12:57:01.977Z
9ea0ae6a-2ebf-474b-9692-9c55f721a06d	backend	GET	/api/committees	200	10	2026-03-11T15:15:21.009Z
630e34d4-ec06-47f3-971c-ac9f7a1c4c77	backend	POST	/api/sms/send	400	6	2026-03-11T15:15:27.253Z
1c8edb4d-027f-4ff0-ae2f-4ba6e686372a	backend	POST	/api/auth/login	200	88	2026-03-11T15:15:32.044Z
7f3a20f0-c0cb-4fde-afc5-fa9fdc53fd65	backend	GET	/api/branches	403	2	2026-03-11T15:15:39.548Z
e959f34c-d895-4e3d-9e06-59a2b5dccf37	backend	GET	/api/departments	200	6	2026-03-11T15:16:20.407Z
bbd8276c-d935-4ac9-9ef1-0b74387ab713	backend	GET	/api/members?q=Grace&page=1&pageSize=10	200	5	2026-03-11T15:16:45.304Z
3463895a-0ddc-4788-95d8-7d591676f6e4	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	16	2026-03-11T12:57:02.018Z
8c756219-54b1-4a52-88a0-af3e0039c24d	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	24	2026-03-11T12:57:02.021Z
707a066c-5f2a-4b4f-940d-e38d823fd3cd	ui	NAV	/membership	200	83	2026-03-11T12:57:01.569Z
1834fd61-c596-4082-9202-74540a1ed6ce	backend	GET	/api/users	200	15	2026-03-11T15:18:38.346Z
5d2e873e-b8d2-4a93-ae52-384bd7f456c8	backend	GET	/api/departments/heads	200	8	2026-03-11T15:18:38.555Z
81624474-de5d-4d89-9a73-992e02440088	backend	GET	/api/users	403	2	2026-03-11T15:18:47.861Z
f9658cfc-0aa1-456d-aa96-087e273feed0	backend	GET	/api/branches	403	3	2026-03-11T15:18:48.061Z
28e90937-c904-47bd-92a3-744e2d436ed9	backend	GET	/api/departments/roles	200	29	2026-03-11T13:02:20.310Z
06cd9b65-be44-45ef-b467-f761beb5156f	backend	GET	/api/branches	200	25	2026-03-11T15:18:38.359Z
b7862356-5393-437a-96f3-f6bf98ce10aa	backend	GET	/api/committees/chairs	200	6	2026-03-11T15:18:47.858Z
2496255f-e283-4cec-9a39-8c98b37c7082	backend	GET	/api/members?page=1&pageSize=10&sort=name%2Casc	200	43	2026-03-11T13:02:20.316Z
7e665a40-783b-40ba-b224-98f528738fb7	backend	GET	/api/departments/5e6f844c-e002-49a6-94a0-dfc334e10986/members?page=1&pageSize=500	200	11	2026-03-11T13:02:20.393Z
361c8853-7b95-4636-a101-c71d1d12925d	backend	GET	/api/departments/c2088c8a-395c-4640-8457-9b5d854a6864/members?page=1&pageSize=500	200	14	2026-03-11T13:02:20.400Z
653cd454-e7b1-4170-a476-4afee835db42	backend	GET	/api/departments/5da01ccc-2a8a-4dc7-94f4-deac5493cdb3/members?page=1&pageSize=500	200	14	2026-03-11T13:02:20.400Z
2c61d390-2713-4680-b8fa-2364694a65a9	backend	GET	/api/departments/b9babf01-eece-4615-b5e0-317d3d86d3fa/members?page=1&pageSize=500	200	19	2026-03-11T13:02:20.406Z
3a3d042a-8552-4dd1-98d6-9e2b016df134	backend	GET	/api/committees/3146786c-8d42-414d-b9af-a6987818575e/members?page=1&pageSize=500	200	16	2026-03-11T13:02:20.439Z
3edc5528-390d-49cd-9f7c-cabf08c56ded	backend	GET	/api/departments/heads	200	48	2026-03-11T13:02:20.331Z
ae6351a3-eceb-428f-8f71-fe0a21a22723	backend	GET	/api/departments?page=1&pageSize=200	200	54	2026-03-11T13:02:20.333Z
14d6a47b-e71a-4e47-b796-47b5b5371d73	backend	GET	/api/members?page=1&pageSize=500	200	5	2026-03-11T13:02:20.343Z
85064516-319d-415c-8f35-60048dd5eba8	backend	GET	/api/committees/chairs	200	5	2026-03-11T13:02:20.366Z
0f9902ff-69bc-43de-87d5-ef559023517f	backend	GET	/api/members/pastors	200	4	2026-03-11T13:02:20.375Z
271c9e44-519b-4105-b41d-561eed123b76	backend	GET	/api/departments/85250359-576b-4a18-8227-aa0d4b28f7d1/members?page=1&pageSize=500	200	15	2026-03-11T13:02:20.410Z
de7cc188-a685-4f9f-b102-aa02d0d20540	backend	GET	/api/departments/aa98b455-b7f2-4079-8aa9-a6a3f093be3e/members?page=1&pageSize=500	200	12	2026-03-11T13:02:20.410Z
c8347429-d461-46bf-8500-97d469a71cd9	backend	GET	/api/committees/534677a7-d17a-4ab3-a004-57f2c4d0069f/members?page=1&pageSize=500	200	18	2026-03-11T13:02:20.438Z
42080c96-997d-4aeb-848f-c06448dadec3	backend	GET	/api/committees?page=1&pageSize=200	200	8	2026-03-11T13:02:20.356Z
f9431dc2-a6cd-4a8e-bf72-d8ee240c65d5	backend	GET	/api/departments/140bb6eb-e7b6-443e-9711-c004249caba8/members?page=1&pageSize=500	200	12	2026-03-11T13:02:20.396Z
675b3e07-f39b-4f22-9d4a-1b1c8a00edf4	backend	GET	/api/committees/7f974c34-bf63-4777-b923-c12e244538e8/members?page=1&pageSize=500	200	12	2026-03-11T13:02:20.439Z
b663756e-3004-4c4e-ab9f-708b8a48578c	backend	GET	/api/departments/0d4e1f8d-09df-4ba6-98df-5b5973bff572/members?page=1&pageSize=500	200	13	2026-03-11T13:02:20.402Z
090ffd9c-7dea-4be1-985d-cddb2f431c4b	backend	GET	/api/departments/84fc7f08-be74-487c-8e37-9382734b0484/members?page=1&pageSize=500	200	9	2026-03-11T13:02:20.413Z
a736fb5f-2e81-4ff1-8fcd-f40f8afd897a	backend	GET	/api/departments/fdcb71bd-17bf-461f-803c-ea4fbde3a292/members?page=1&pageSize=500	200	9	2026-03-11T13:02:20.414Z
4fd591e5-f0f1-4e67-8d68-42079d0675f1	backend	GET	/api/committees/24d1558c-75e8-48da-b220-dcd7a9ccb554/members?page=1&pageSize=500	200	11	2026-03-11T13:02:20.436Z
67f4df85-0a1d-41e7-9240-f7044e769b20	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	16	2026-03-11T13:02:20.438Z
93ad1470-a020-45a3-9358-418047080220	backend	GET	/api/committees/af7369ed-0931-411e-afa2-2514fa8c27d6/members?page=1&pageSize=500	200	9	2026-03-11T12:09:41.394Z
\.


--
-- Data for Name: members; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.members (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, date_joined, department, email, gender, name, phone, role, status) FROM stdin;
3a0218c7-554a-4342-8cad-a138701b0dca	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	john.otieno@church.local	Male	Rev. John Otieno	0722001101	Senior Pastor	Active
a45e59f5-bfd0-49d3-806b-90a68f1e1bf5	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	grace.wanjiku@church.local	Female	Grace Wanjiku	0722001102	Associate Pastor	Active
de2bb05a-ad45-4fd7-9581-7ba1764f53ad	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	peter.mwangi@church.local	Male	Peter Mwangi	0722001103	Member	Active
293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	mary.akinyi@church.local	Female	Mary Akinyi	0722001104	Member	Active
b818dbc7-388b-4263-9b05-e118a9a1f341	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	joseph.kiptoo@church.local	Male	Joseph Kiptoo	0722001105	Member	Active
46fbb0f6-118d-4758-b841-42a499b92969	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	anne.njeri@church.local	Female	Anne Njeri	0722001106	Member	Active
b401279c-6ade-4def-a173-4858beaa411a	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	david.ochieng@church.local	Male	David Ochieng	0722001107	Member	Active
0715a7d7-9ca9-45ec-b2cc-7d07ba614d76	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	sarah.chebet@church.local	Female	Sarah Chebet	0722001108	Member	Active
189cf488-3218-48fc-803d-10f2d1fdb7c8	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	brian.kimani@church.local	Male	Brian Kimani	0722001109	Member	Active
59b0c882-4d10-4aa8-b337-34698c628f24	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	lucy.mutiso@church.local	Female	Lucy Mutiso	0722001110	Member	Active
73c90865-0666-48c5-831b-5fb7c44685ab	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	samuel.kiplagat@church.local	Male	Samuel Kiplagat	0722001111	Youth Pastor	Active
30134799-913f-4f8e-ac16-78e7971db70d	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	esther.waithera@church.local	Female	Esther Waithera	0722001112	Member	Active
7e49d02c-53fa-43f1-9fd2-c8253964e6f9	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	paul.kariuki@church.local	Male	Paul Kariuki	0722001113	Member	Active
4130fa81-d1d6-40e1-9f84-a34ef7c62a15	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	jane.nyambura@church.local	Female	Jane Nyambura	0722001114	Member	Active
7d6c7b03-2ee2-4b2a-8105-34a579427b63	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	daniel.mutua@church.local	Male	Daniel Mutua	0722001115	Member	Active
ad1d8478-d13c-43a7-9335-c5910979cbfb	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	faith.wairimu@church.local	Female	Faith Wairimu	0722001116	Member	Active
b67ce892-1bb5-4967-bd81-488a39722945	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	kevin.wamalwa@church.local	Male	Kevin Wamalwa	0722001117	Member	Active
d2bbee57-7601-440e-8684-b383606bac79	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	2026-03-11	\N	rose.atieno@church.local	Female	Rose Atieno	0722001118	Member	Active
2bfed722-86e6-48be-a93b-3a6f64a853e7	2026-03-11T11:47:50.622Z	5365cc82-1f96-4b9f-91b1-2476bc2e3a4a	2026-03-11T11:47:50.622Z	5365cc82-1f96-4b9f-91b1-2476bc2e3a4a	\N	2026-03-11	\N	test.member2@church.local	\N	Test Member	+256700000123	\N	Active
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.permissions (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, description, name) FROM stdin;
d509f828-cf99-4d60-ac79-e4117f9c90d7	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	READ ALL	READ_ALL
0d42332a-7bb6-4d09-920b-c844b9210992	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	MEMBER CREATE	MEMBER_CREATE
8aefc6b9-7854-4f4e-ae96-5f4e19b2fddd	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	MEMBER UPDATE	MEMBER_UPDATE
4715754f-96c9-4a53-b8db-330bface7da0	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	MEMBER DELETE	MEMBER_DELETE
089703f3-1306-4dc1-8a53-e21de81f9b04	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	DEPARTMENT CREATE	DEPARTMENT_CREATE
079ec08c-2982-4596-8edc-90e758e9a456	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	DEPARTMENT UPDATE	DEPARTMENT_UPDATE
d7640c6a-773e-426a-834f-ec2dd28761a4	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	DEPARTMENT DEACTIVATE	DEPARTMENT_DEACTIVATE
c1e7b5bd-2e52-4b36-9b60-8507a70ef9a4	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	DEPT MEMBER ADD	DEPT_MEMBER_ADD
ab0dfd98-781f-4130-bbda-45fb59075ba1	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	DEPT MEMBER REMOVE	DEPT_MEMBER_REMOVE
72c8fc30-7ac8-4566-bf52-eed0a6dd025e	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	COMMITTEE CREATE	COMMITTEE_CREATE
64e89450-49aa-4016-a19e-39c43cbf3281	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	COMMITTEE UPDATE	COMMITTEE_UPDATE
94befa57-c824-4c3b-ba92-c2a809b08a69	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	COMMITTEE DEACTIVATE	COMMITTEE_DEACTIVATE
42032141-e64d-4c2b-a45e-a9a104f2b0d9	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	COMMITTEE MEMBER ADD	COMMITTEE_MEMBER_ADD
cc4775c0-05ab-49d0-8470-fdc2a358a711	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	COMMITTEE MEMBER REMOVE	COMMITTEE_MEMBER_REMOVE
1516b7bd-04df-48f3-9b5c-0aceecb4884f	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	SMS SEND	SMS_SEND
2d86362c-600f-45ef-97b6-9293886a3941	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	SMS VIEW	SMS_VIEW
284df0be-496c-4cfe-87f9-2d751273cf04	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	USER CREATE	USER_CREATE
dd4e275f-66df-436e-b054-b5eb7aac7be6	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	USER UPDATE	USER_UPDATE
99207c2c-6108-4034-8872-170e3017d0f8	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	USER DEACTIVATE	USER_DEACTIVATE
72362ac8-8433-43fe-bdcf-6c7eeae461b2	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	USER RESET PASSWORD	USER_RESET_PASSWORD
706dec86-6645-450f-ba7e-237673981102	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	GROUP CREATE	GROUP_CREATE
9c83b2f8-3027-44a1-a76a-dbae8bc28553	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	GROUP UPDATE	GROUP_UPDATE
52c85bd3-5dcc-4d41-b26c-a7af4f2939c8	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	GROUP ASSIGN ROLES	GROUP_ASSIGN_ROLES
446b7387-b69c-4882-ad37-4d0493a54fc1	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	USER ASSIGN GROUPS	USER_ASSIGN_GROUPS
8c35ef97-eb8b-4127-bb71-8f9e761c2e6d	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	ROLE VIEW	ROLE_VIEW
08c9006c-510b-455e-bbb0-b10980b4e5a0	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	PERMISSION VIEW	PERMISSION_VIEW
c6c44f6f-963b-4a45-b89d-77a7a014d9c1	2026-03-11 12:26:01.986016+03	system	2026-03-11 12:26:01.986016+03	system	\N	Create branches	BRANCH_CREATE
c9da882f-b72f-42d2-bb01-1575eb67a87d	2026-03-11 12:26:01.989953+03	system	2026-03-11 12:26:01.989953+03	system	\N	Update branches	BRANCH_UPDATE
6d9434fd-b101-4f33-a9be-cee944f2582e	2026-03-11 12:26:01.990404+03	system	2026-03-11 12:26:01.990404+03	system	\N	Deactivate branches	BRANCH_DEACTIVATE
cf688979-9d74-47b6-b62c-e1a1197a05ef	2026-03-11 12:26:01.991896+03	system	2026-03-11 12:26:01.991896+03	system	\N	Assign pastors to branches	BRANCH_PASTOR_ADD
f0582196-3725-4f26-8183-f7ea7e1aefae	2026-03-11 12:26:01.992573+03	system	2026-03-11 12:26:01.992573+03	system	\N	Remove pastors from branches	BRANCH_PASTOR_REMOVE
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.refresh_tokens (id, user_id, token_hash, created_at, expires_at, revoked_at, replaced_by, last_used_at) FROM stdin;
09b0063a-18ac-4471-a5f0-dd35ea455285	5365cc82-1f96-4b9f-91b1-2476bc2e3a4a	6651aeeba1f5d0c0849eef511de2e8058e237367509bbe48520d257b65497bd3	2026-03-11T11:46:40.782Z	2026-03-18T11:46:40.782Z	2026-03-11T11:48:21.098Z	0ee9dd1492c9c7d4246ef5696563289a2ece905b319f7903f8259236b46dd2cd	2026-03-11T11:48:21.098Z
81b4d37c-2d59-4dfd-b26b-5b03c42cea0b	5365cc82-1f96-4b9f-91b1-2476bc2e3a4a	0ee9dd1492c9c7d4246ef5696563289a2ece905b319f7903f8259236b46dd2cd	2026-03-11T11:48:09.828Z	2026-03-18T11:48:09.833Z	2026-03-11T11:48:21.098Z	\N	2026-03-11T11:48:21.098Z
85210926-6528-410b-bc9c-7cf39ba0326c	5365cc82-1f96-4b9f-91b1-2476bc2e3a4a	e6baeb0de2996b81021dcda403b281f76ee328e1690a9e939ff65367575e72b3	2026-03-11T11:48:29.321Z	2026-03-18T11:48:29.321Z	\N	\N	\N
7d825e46-b4b3-4e27-9db2-21396f889199	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	b0708139c8f07956771b8ad372a2720e80710aeec8e622835314faed6862e632	2026-03-11T11:54:07.300Z	2026-03-18T11:54:07.300Z	2026-03-11T15:07:29.684Z	5e780a81244fe326231e273078b061c599dd76d4e9706fcdac0c0399c0b6ddb0	2026-03-11T15:07:29.684Z
5dd18c2c-69de-480f-9566-b2678afec56e	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	5e780a81244fe326231e273078b061c599dd76d4e9706fcdac0c0399c0b6ddb0	2026-03-11T15:07:29.684Z	2026-03-18T15:07:29.703Z	\N	\N	\N
e8ed4422-bfa8-475e-a07d-7fb3b0845146	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	ac3fd0dcc6fc30fcbab04277d07172cdae6f4dfca0c564ab7e49c1bf8ccca728	2026-03-11T15:10:29.286Z	2026-03-18T15:10:29.286Z	\N	\N	\N
d2d4120e-1e05-43e0-ac03-ef4ad9e23889	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	9f3bfa65c4891aebe2e592673de6a4528ffb831e554ce3f7219ddda6ea2a6e10	2026-03-11T15:11:23.246Z	2026-03-18T15:11:23.247Z	\N	\N	\N
2eded3dc-6473-41a8-a6d0-823912eff146	854b3e73-e9ed-4d78-9502-f43d05add677	e19d620e69be379edeec541e6f9c6975b01c025f4607c21273d3d8b4df9cb622	2026-03-11T15:12:31.761Z	2026-03-18T15:12:31.762Z	\N	\N	\N
90559bed-7a84-4e76-9947-3dce1c66bab6	293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	10aac579b581d66e1b7ed5dde4a521184ae9f2e85454b3306b1b12b53c6b4390	2026-03-11T15:13:55.171Z	2026-03-18T15:13:55.171Z	\N	\N	\N
6861cd59-4d05-4717-9624-21a1ea1b3b17	1c09be18-bfd2-4a78-abdb-d39209ec7100	0cef4de7ea27cc83d4da1b38ea89cfba03663e7a904ec871f4455d806a12bebf	2026-03-11T15:15:32.042Z	2026-03-18T15:15:32.042Z	\N	\N	\N
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.role_permissions (id, permission_id, role_id) FROM stdin;
b7783c74-4847-40f5-8497-a9a0ea7185ea	d509f828-cf99-4d60-ac79-e4117f9c90d7	7f2d3793-85aa-41ea-b3c7-4422a915a86f
44db4ee2-8fbf-4436-b67e-0bbcad8f70b3	0d42332a-7bb6-4d09-920b-c844b9210992	7f2d3793-85aa-41ea-b3c7-4422a915a86f
2544ebd5-bdfe-4f46-92e5-f6017e5f69d2	8aefc6b9-7854-4f4e-ae96-5f4e19b2fddd	7f2d3793-85aa-41ea-b3c7-4422a915a86f
6f04dbb0-ea86-4ed2-9d01-19315b03bfc0	4715754f-96c9-4a53-b8db-330bface7da0	7f2d3793-85aa-41ea-b3c7-4422a915a86f
8a5c1820-41e8-481e-833d-73b21ca2f79b	089703f3-1306-4dc1-8a53-e21de81f9b04	7f2d3793-85aa-41ea-b3c7-4422a915a86f
450649bc-f285-483c-9233-4c5413b0e037	079ec08c-2982-4596-8edc-90e758e9a456	7f2d3793-85aa-41ea-b3c7-4422a915a86f
51ebfff8-e83f-4c8f-b660-abc7fef96519	d7640c6a-773e-426a-834f-ec2dd28761a4	7f2d3793-85aa-41ea-b3c7-4422a915a86f
15deb0a9-8a9b-4364-9f5a-a855d56a1a2a	c1e7b5bd-2e52-4b36-9b60-8507a70ef9a4	7f2d3793-85aa-41ea-b3c7-4422a915a86f
171c2b3b-6046-48c0-a881-455afab0204c	ab0dfd98-781f-4130-bbda-45fb59075ba1	7f2d3793-85aa-41ea-b3c7-4422a915a86f
4fa37a0c-4aef-474b-977c-69daf2a5fc67	72c8fc30-7ac8-4566-bf52-eed0a6dd025e	7f2d3793-85aa-41ea-b3c7-4422a915a86f
e15bdec8-0746-463a-a6e1-554f8bf209d2	64e89450-49aa-4016-a19e-39c43cbf3281	7f2d3793-85aa-41ea-b3c7-4422a915a86f
c4e6259e-bc3a-4785-8c5c-8829c0d191d1	94befa57-c824-4c3b-ba92-c2a809b08a69	7f2d3793-85aa-41ea-b3c7-4422a915a86f
db31e480-a2bb-4511-87bf-49d47287c8b9	42032141-e64d-4c2b-a45e-a9a104f2b0d9	7f2d3793-85aa-41ea-b3c7-4422a915a86f
7a8157c9-106c-40cb-86ae-b67602172459	cc4775c0-05ab-49d0-8470-fdc2a358a711	7f2d3793-85aa-41ea-b3c7-4422a915a86f
85a84c81-2007-4458-a65d-c8a66aa7df0b	1516b7bd-04df-48f3-9b5c-0aceecb4884f	7f2d3793-85aa-41ea-b3c7-4422a915a86f
dfacf312-1c1c-4a2a-94df-91378c4c556f	2d86362c-600f-45ef-97b6-9293886a3941	7f2d3793-85aa-41ea-b3c7-4422a915a86f
0495294b-5b54-4294-abef-c321f37ad59f	284df0be-496c-4cfe-87f9-2d751273cf04	7f2d3793-85aa-41ea-b3c7-4422a915a86f
f4e51bf7-358f-4915-871e-b9835bd84fd1	dd4e275f-66df-436e-b054-b5eb7aac7be6	7f2d3793-85aa-41ea-b3c7-4422a915a86f
61216cb9-2be9-47b7-844d-d127d9b69850	99207c2c-6108-4034-8872-170e3017d0f8	7f2d3793-85aa-41ea-b3c7-4422a915a86f
c1d38d0f-e495-4b7c-a713-ad87b61674ff	72362ac8-8433-43fe-bdcf-6c7eeae461b2	7f2d3793-85aa-41ea-b3c7-4422a915a86f
39b07113-9c09-4597-9bde-ac66f1c89e03	706dec86-6645-450f-ba7e-237673981102	7f2d3793-85aa-41ea-b3c7-4422a915a86f
86a63944-297f-4c50-bf6f-9dc2327d1dc7	9c83b2f8-3027-44a1-a76a-dbae8bc28553	7f2d3793-85aa-41ea-b3c7-4422a915a86f
b29daa32-e99b-4c31-ba5f-6501eb7c9549	52c85bd3-5dcc-4d41-b26c-a7af4f2939c8	7f2d3793-85aa-41ea-b3c7-4422a915a86f
57e59672-5a00-4f5e-ba92-8c82ae6f8687	446b7387-b69c-4882-ad37-4d0493a54fc1	7f2d3793-85aa-41ea-b3c7-4422a915a86f
f0fffff6-ac27-43d3-a6d1-27e561c42462	8c35ef97-eb8b-4127-bb71-8f9e761c2e6d	7f2d3793-85aa-41ea-b3c7-4422a915a86f
17508052-5622-4e13-9628-97f9088afb3b	08c9006c-510b-455e-bbb0-b10980b4e5a0	7f2d3793-85aa-41ea-b3c7-4422a915a86f
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.roles (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, description, name) FROM stdin;
7f2d3793-85aa-41ea-b3c7-4422a915a86f	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	Full access	Super Admin
1badaed8-e034-4fbc-9444-00dccf064485	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	Administrative access	Admin
5a9f8573-998f-4c4f-a13b-e68b205bf2a3	2026-03-10T14:51:14.303106312+03:00	system	2026-03-10T14:51:14.303151016+03:00	system	\N	Read only	Member
\.


--
-- Data for Name: sms_records; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.sms_records (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, date, message, recipient_count, recipient_type, recipients, status, provider_code, provider_message, provider_response, provider_status) FROM stdin;
\.


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.user_groups (id, group_id, user_id) FROM stdin;
f025aff7-d807-4a7c-9d17-2040f5600513	c696730a-7cdc-42dd-bcb7-a94c1e48662b	854b3e73-e9ed-4d78-9502-f43d05add677
c090f85f-6839-4ac7-bc61-d842478f5da2	59fdb9ce-f8c7-460f-8ef9-58fd3294259d	1c09be18-bfd2-4a78-abdb-d39209ec7100
290156b7-c414-4326-979f-58297ab64c0b	57699093-83ec-4aef-b1a4-1c6118817520	293be6b6-c24f-4fbe-9f09-e0c3cf477ac3
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: peniel
--

COPY public.users (id, created_at, created_by, last_edited_at, last_edited_by, sent_by, email, name, password_hash, role, status, phone) FROM stdin;
dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	admin@church.local	Admin Mwikali	$2a$10$JtO6cSb9vDTZkZ59H0.i3uLL1M5xo1cqV2eQe84SK3n3tVdq7F5Fe	Super Admin	Active	+254700000001
2fef893c-6fd1-4929-92e7-b6af0cec4132	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	pastor@church.local	Pastor Otieno	$2a$10$mTVLWdvs1UD/552Md0py3u1pDwmRYigM7O36EXulExskqu/SJ0j9.	Admin	Active	+254700000002
528c4843-72f8-413e-a09c-80167d54378b	2026-03-11T08:48:06.241Z	system	2026-03-11T08:48:06.241Z	system	\N	ruth.wanjiru@church.local	Ruth Wanjiru	$2a$10$wB0LRzgG14ylTlmmghQ91.VD69yDAG8zKeY3mvvWXHJBGcYhYIq0C	Department Head	Active	+254700000003
5365cc82-1f96-4b9f-91b1-2476bc2e3a4a	2026-03-11THH24:45:42.385Z	system	2026-03-11THH24:45:42.385Z	system	\N	superadmin@church.local	Super Admin	$2a$10$iT4oBRpMf.u5KvkPnKfQSet1RbvReBSILvg13pWwftmkpW8p.24ou	Super Admin	Active	+256700000002
5c4f3367-d238-42b3-adaa-db8fba79f285	2026-03-11T15:10:40.670Z	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	2026-03-11T15:10:40.670Z	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	\N	wanjiru.super@church.local	Wanjiru Kariuki	$2a$10$qSqxN6mmnSSSAmmAKDjwx.lRaIhs52/zbthWl3f5so7lpwF8rdJo.	Super Admin	Active	+254700900010
854b3e73-e9ed-4d78-9502-f43d05add677	2026-03-11T15:11:40.496Z	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	2026-03-11T15:11:40.496Z	dc3b0f9a-ab0c-43bf-baf1-e32d65623dbd	\N	wanjiru.super2@church.local	Wanjiru Kariuki	$2a$10$69ngi3LLmemZEbLfpAQuR.iCP1AUl/euGzq6lWcP8r9JPPKgNicFS	Super Admin	Active	+254700900011
1c09be18-bfd2-4a78-abdb-d39209ec7100	2026-03-11T15:13:39.596Z	854b3e73-e9ed-4d78-9502-f43d05add677	2026-03-11T15:13:39.596Z	854b3e73-e9ed-4d78-9502-f43d05add677	\N	kamau.admin@church.local	Kamau Njoroge	$2a$10$2xqatWWHiZ93NNrT9MP9pe6sAUlr5dEelXcMAYQ3PcoO27oHiu3VC	Admin	Active	+254700900020
293be6b6-c24f-4fbe-9f09-e0c3cf477ac3	2026-03-11T15:13:50.858Z	854b3e73-e9ed-4d78-9502-f43d05add677	2026-03-11T15:13:50.858Z	854b3e73-e9ed-4d78-9502-f43d05add677	\N	mary.akinyi@church.local	Mary Akinyi	$2a$10$grjqh.umhX1N.hvu6FuREeIKRKU/BiOWpMp4l1JPRmr8pCRBctIga	Leader	Active	0722001104
\.


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: branch_pastors branch_pastors_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.branch_pastors
    ADD CONSTRAINT branch_pastors_pkey PRIMARY KEY (id);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: committee_members committee_members_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.committee_members
    ADD CONSTRAINT committee_members_pkey PRIMARY KEY (id);


--
-- Name: committees committees_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.committees
    ADD CONSTRAINT committees_pkey PRIMARY KEY (id);


--
-- Name: department_members department_members_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.department_members
    ADD CONSTRAINT department_members_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: group_roles group_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.group_roles
    ADD CONSTRAINT group_roles_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: latency_logs latency_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.latency_logs
    ADD CONSTRAINT latency_logs_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sms_records sms_records_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.sms_records
    ADD CONSTRAINT sms_records_pkey PRIMARY KEY (id);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_activities_time; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_activities_time ON public.activities USING btree ("time");


--
-- Name: idx_branch_pastors_branch_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_branch_pastors_branch_id ON public.branch_pastors USING btree (branch_id);


--
-- Name: idx_branch_pastors_member_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_branch_pastors_member_id ON public.branch_pastors USING btree (member_id);


--
-- Name: idx_branch_pastors_unique; Type: INDEX; Schema: public; Owner: peniel
--

CREATE UNIQUE INDEX idx_branch_pastors_unique ON public.branch_pastors USING btree (branch_id, member_id);


--
-- Name: idx_branches_status; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_branches_status ON public.branches USING btree (status);


--
-- Name: idx_comm_members_committee; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_comm_members_committee ON public.committee_members USING btree (committee_id);


--
-- Name: idx_comm_members_member; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_comm_members_member ON public.committee_members USING btree (member_id);


--
-- Name: idx_committee_members_committee_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_committee_members_committee_id ON public.committee_members USING btree (committee_id);


--
-- Name: idx_committee_members_member_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_committee_members_member_id ON public.committee_members USING btree (member_id);


--
-- Name: idx_committees_name; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_committees_name ON public.committees USING btree (name);


--
-- Name: idx_committees_status; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_committees_status ON public.committees USING btree (status);


--
-- Name: idx_department_members_department_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_department_members_department_id ON public.department_members USING btree (department_id);


--
-- Name: idx_department_members_member_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_department_members_member_id ON public.department_members USING btree (member_id);


--
-- Name: idx_departments_name; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_departments_name ON public.departments USING btree (name);


--
-- Name: idx_departments_status; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_departments_status ON public.departments USING btree (status);


--
-- Name: idx_dept_members_dept; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_dept_members_dept ON public.department_members USING btree (department_id);


--
-- Name: idx_dept_members_member; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_dept_members_member ON public.department_members USING btree (member_id);


--
-- Name: idx_group_roles_group; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_group_roles_group ON public.group_roles USING btree (group_id);


--
-- Name: idx_group_roles_group_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_group_roles_group_id ON public.group_roles USING btree (group_id);


--
-- Name: idx_group_roles_role; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_group_roles_role ON public.group_roles USING btree (role_id);


--
-- Name: idx_group_roles_role_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_group_roles_role_id ON public.group_roles USING btree (role_id);


--
-- Name: idx_latency_logs_duration; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_latency_logs_duration ON public.latency_logs USING btree (duration_ms);


--
-- Name: idx_latency_logs_source; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_latency_logs_source ON public.latency_logs USING btree (source);


--
-- Name: idx_latency_logs_timestamp; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_latency_logs_timestamp ON public.latency_logs USING btree ("timestamp");


--
-- Name: idx_members_date_joined; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_members_date_joined ON public.members USING btree (date_joined);


--
-- Name: idx_members_email; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_members_email ON public.members USING btree (email);


--
-- Name: idx_members_email_unique; Type: INDEX; Schema: public; Owner: peniel
--

CREATE UNIQUE INDEX idx_members_email_unique ON public.members USING btree (lower((email)::text)) WHERE (email IS NOT NULL);


--
-- Name: idx_members_name; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_members_name ON public.members USING btree (name);


--
-- Name: idx_members_phone; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_members_phone ON public.members USING btree (phone);


--
-- Name: idx_members_phone_unique; Type: INDEX; Schema: public; Owner: peniel
--

CREATE UNIQUE INDEX idx_members_phone_unique ON public.members USING btree (phone) WHERE (phone IS NOT NULL);


--
-- Name: idx_members_status; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_members_status ON public.members USING btree (status);


--
-- Name: idx_refresh_tokens_hash; Type: INDEX; Schema: public; Owner: peniel
--

CREATE UNIQUE INDEX idx_refresh_tokens_hash ON public.refresh_tokens USING btree (token_hash);


--
-- Name: idx_refresh_tokens_user; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_refresh_tokens_user ON public.refresh_tokens USING btree (user_id);


--
-- Name: idx_role_permissions_permission; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_role_permissions_permission ON public.role_permissions USING btree (permission_id);


--
-- Name: idx_role_permissions_permission_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_role_permissions_permission_id ON public.role_permissions USING btree (permission_id);


--
-- Name: idx_role_permissions_role; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_role_permissions_role ON public.role_permissions USING btree (role_id);


--
-- Name: idx_role_permissions_role_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_role_permissions_role_id ON public.role_permissions USING btree (role_id);


--
-- Name: idx_sms_date; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_sms_date ON public.sms_records USING btree (date);


--
-- Name: idx_sms_records_date; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_sms_records_date ON public.sms_records USING btree (date);


--
-- Name: idx_sms_records_recipient_type; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_sms_records_recipient_type ON public.sms_records USING btree (recipient_type);


--
-- Name: idx_sms_records_status; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_sms_records_status ON public.sms_records USING btree (status);


--
-- Name: idx_sms_status; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_sms_status ON public.sms_records USING btree (status);


--
-- Name: idx_user_groups_group; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_user_groups_group ON public.user_groups USING btree (group_id);


--
-- Name: idx_user_groups_group_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_user_groups_group_id ON public.user_groups USING btree (group_id);


--
-- Name: idx_user_groups_user; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_user_groups_user ON public.user_groups USING btree (user_id);


--
-- Name: idx_user_groups_user_id; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_user_groups_user_id ON public.user_groups USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_status; Type: INDEX; Schema: public; Owner: peniel
--

CREATE INDEX idx_users_status ON public.users USING btree (status);


--
-- Name: branch_pastors branch_pastors_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.branch_pastors
    ADD CONSTRAINT branch_pastors_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id) ON DELETE CASCADE;


--
-- Name: branch_pastors branch_pastors_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.branch_pastors
    ADD CONSTRAINT branch_pastors_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: peniel
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict z6LfgJKexjyb65Sm5xW7cys6xJM1o4aDgPtH3abCqTbuictzGWfkHDzigcbc2VH

