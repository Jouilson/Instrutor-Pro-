-- Instrutor Pro V11 - estrutura mínima esperada pelo frontend
-- Execute no Supabase SQL Editor somente se essas tabelas ainda não existirem.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'instrutor' check (role in ('instrutor','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  instructor_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  email text,
  phone text,
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  instructor_id uuid not null references auth.users(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  scheduled_at timestamptz not null,
  type text not null default 'pratica',
  status text not null default 'agendada',
  created_at timestamptz not null default now()
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  instructor_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid references public.activities(id) on delete cascade,
  question text not null,
  answer text,
  created_at timestamptz not null default now()
);

create table if not exists public.attempts (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  activity_id uuid references public.activities(id) on delete set null,
  score numeric not null default 0,
  max_score numeric not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  instructor_id uuid not null references auth.users(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  amount numeric(12,2) not null default 0,
  method text,
  status text not null default 'pendente',
  due_date date,
  created_at timestamptz not null default now()
);

-- Cria o perfil automaticamente para novos usuários.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, role)
  values (new.id, 'instrutor')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- RLS
alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.lessons enable row level security;
alter table public.activities enable row level security;
alter table public.questions enable row level security;
alter table public.attempts enable row level security;
alter table public.payments enable row level security;

-- Profiles: cada usuário pode ver/editar seu próprio perfil.
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles for select using (id = auth.uid());
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

-- Tabelas pertencentes ao instrutor autenticado.
drop policy if exists students_all_own on public.students;
create policy students_all_own on public.students for all using (instructor_id = auth.uid()) with check (instructor_id = auth.uid());

drop policy if exists lessons_all_own on public.lessons;
create policy lessons_all_own on public.lessons for all using (instructor_id = auth.uid()) with check (instructor_id = auth.uid());

drop policy if exists activities_all_own on public.activities;
create policy activities_all_own on public.activities for all using (instructor_id = auth.uid()) with check (instructor_id = auth.uid());

drop policy if exists payments_all_own on public.payments;
create policy payments_all_own on public.payments for all using (instructor_id = auth.uid()) with check (instructor_id = auth.uid());

-- Questions/attempts são acessíveis quando pertencem ao instrutor por atividade/aluno.
drop policy if exists questions_all_own on public.questions;
create policy questions_all_own on public.questions for all using (
  exists (select 1 from public.activities a where a.id = questions.activity_id and a.instructor_id = auth.uid())
) with check (
  exists (select 1 from public.activities a where a.id = questions.activity_id and a.instructor_id = auth.uid())
);

drop policy if exists attempts_all_own on public.attempts;
create policy attempts_all_own on public.attempts for all using (
  exists (select 1 from public.students s where s.id = attempts.student_id and s.instructor_id = auth.uid())
) with check (
  exists (select 1 from public.students s where s.id = attempts.student_id and s.instructor_id = auth.uid())
);
