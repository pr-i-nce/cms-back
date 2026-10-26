import { prisma } from "../db/client.js";
import { env } from "../config/env.js";
import { cached } from "../utils/cache.js";

export type PermissionContext = {
  hasGroups: boolean;
  permissions: string[];
};

export const resolvePermissionContext = (userId: string): Promise<PermissionContext> => cached(
  `permissions:user:${userId}`,
  env.cacheTtl.permissionsMs,
  async () => {
    const [context] = await prisma.$queryRaw<PermissionContext[]>`
      with assigned_groups as materialized (
        select g.id, g.name
        from user_groups ug
        join groups g on g.id = ug.group_id
        where ug.user_id = ${userId}::uuid
      ), assigned_roles as materialized (
        select distinct gr.role_id
        from group_roles gr
        join assigned_groups ag on ag.id = gr.group_id
      ), resolved_permissions as materialized (
        select distinct p.name
        from role_permissions rp
        join assigned_roles ar on ar.role_id = rp.role_id
        join permissions p on p.id = rp.permission_id
        where p.name is not null
      )
      select
        exists(select 1 from assigned_groups) as "hasGroups",
        case
          when exists(
            select 1 from assigned_groups
            where lower(coalesce(name, '')) like '%super%'
              and lower(coalesce(name, '')) like '%admin%'
          ) then array(
            select name from permissions where name is not null order by name
          )
          when exists(select 1 from assigned_roles) then array(
            select name from resolved_permissions order by name
          )
          when exists(
            select 1 from assigned_groups
            where lower(coalesce(name, '')) like '%leader%'
          ) then array[
            'DEPARTMENT_UPDATE', 'DEPARTMENT_DEACTIVATE', 'DEPT_MEMBER_ADD',
            'DEPT_MEMBER_REMOVE', 'COMMITTEE_UPDATE', 'COMMITTEE_DEACTIVATE',
            'COMMITTEE_MEMBER_ADD', 'COMMITTEE_MEMBER_REMOVE', 'MEMBER_UPDATE',
            'SMS_SEND', 'SMS_VIEW'
          ]::text[]
          else array[]::text[]
        end as permissions
    `;
    return context ?? { hasGroups: false, permissions: [] };
  },
);

export const resolvePermissions = async (userId: string): Promise<string[]> =>
  (await resolvePermissionContext(userId)).permissions;
