-- 058: saqlangan postlar (Instagram "Saved"). Har foydalanuvchi faqat o'zinikini ko'radi/yozadi.
create table if not exists public.saved_posts (
  user_id    uuid not null references public.profiles(id) on delete cascade,
  post_id    uuid not null references public.posts(id)    on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);

create index if not exists saved_posts_user_created_idx on public.saved_posts (user_id, created_at desc);

alter table public.saved_posts enable row level security;

drop policy if exists "saved_select" on public.saved_posts;
create policy "saved_select" on public.saved_posts
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "saved_insert" on public.saved_posts;
create policy "saved_insert" on public.saved_posts
  for insert to authenticated
  with check (user_id = auth.uid() and public.is_approved() and public.post_is_visible(post_id));

drop policy if exists "saved_delete" on public.saved_posts;
create policy "saved_delete" on public.saved_posts
  for delete to authenticated using (user_id = auth.uid());

revoke all on public.saved_posts from anon;
grant select, insert, delete on public.saved_posts to authenticated;
grant all on public.saved_posts to service_role;
