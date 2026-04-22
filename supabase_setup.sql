-- ================================================================
-- THE KING APP - Supabase Full Setup
-- Copy toàn bộ file này → Supabase Dashboard → SQL Editor → Run
-- ================================================================
--
-- LƯU Ý QUAN TRỌNG:
-- App dùng Firebase Auth (KHÔNG phải Supabase Auth).
-- → auth.uid() sẽ = NULL → RLS dùng auth.uid() sẽ block hết.
-- → File này TẮT RLS để app hoạt động ngay.
-- → Khi nào tích hợp Supabase Auth, hãy bật RLS lại.
-- ================================================================


-- ================================================================
-- 0. XÓA BẢNG CŨ (nếu có) — theo thứ tự FK dependency
-- ================================================================

DROP TABLE IF EXISTS public.love_letters          CASCADE;
DROP TABLE IF EXISTS public.qa_answers           CASCADE;
DROP TABLE IF EXISTS public.wishes               CASCADE;
DROP TABLE IF EXISTS public.documents            CASCADE;
DROP TABLE IF EXISTS public.day_counters         CASCADE;
DROP TABLE IF EXISTS public.budgets              CASCADE;
DROP TABLE IF EXISTS public.transactions         CASCADE;
DROP TABLE IF EXISTS public.finance_categories   CASCADE;
DROP TABLE IF EXISTS public.moment_reactions     CASCADE;
DROP TABLE IF EXISTS public.moments              CASCADE;
DROP TABLE IF EXISTS public.shared_items         CASCADE;
DROP TABLE IF EXISTS public.friendships          CASCADE;
DROP TABLE IF EXISTS public.financial_categories CASCADE;
DROP TABLE IF EXISTS public.notes                CASCADE;
DROP TABLE IF EXISTS public.photos               CASCADE;
DROP TABLE IF EXISTS public.users                CASCADE;

-- Xóa storage policies cũ (nếu có)
DROP POLICY IF EXISTS "moments_select" ON storage.objects;
DROP POLICY IF EXISTS "moments_insert" ON storage.objects;
DROP POLICY IF EXISTS "moments_delete" ON storage.objects;
DROP POLICY IF EXISTS "photos_select"  ON storage.objects;
DROP POLICY IF EXISTS "photos_insert"  ON storage.objects;
DROP POLICY IF EXISTS "photos_delete"  ON storage.objects;
DROP POLICY IF EXISTS "avatars_select" ON storage.objects;
DROP POLICY IF EXISTS "avatars_insert" ON storage.objects;
DROP POLICY IF EXISTS "avatars_update" ON storage.objects;
DROP POLICY IF EXISTS "avatars_delete" ON storage.objects;

-- Xóa policies cũ từ bản trước (tên khác)
DROP POLICY IF EXISTS "Photos storage: anyone can read"      ON storage.objects;
DROP POLICY IF EXISTS "Photos storage: auth users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Photos storage: owner can delete"     ON storage.objects;
DROP POLICY IF EXISTS "Avatars storage: anyone can read"     ON storage.objects;
DROP POLICY IF EXISTS "Avatars storage: auth users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Avatars storage: owner can update"    ON storage.objects;
DROP POLICY IF EXISTS "Avatars storage: owner can delete"    ON storage.objects;

-- Storage buckets: KHÔNG xóa được qua SQL (Supabase chặn).
-- → Dùng INSERT ... ON CONFLICT ở section 5 bên dưới để tạo nếu chưa có.

-- Xóa trigger function cũ
DROP FUNCTION IF EXISTS public.update_updated_at() CASCADE;


-- ================================================================
-- 1. TABLES
-- ================================================================

-- ── users ───────────────────────────────────────────────────────
-- PK = Firebase Auth UID (TEXT, không phải UUID)
-- Code: _supabaseClient.from('users').upsert(user.toJson(), onConflict: 'uid')
-- Code: .from('users').select().eq('uid', user.uid).single()
-- Code: .from('users').select().neq('uid', user.uid).or('email.ilike.%q%,display_name.ilike.%q%')
CREATE TABLE public.users (
  uid         TEXT        PRIMARY KEY,
  email       TEXT        NOT NULL,
  display_name TEXT,
  photo_url   TEXT,
  bio         TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ── notes ───────────────────────────────────────────────────────
-- Code: .from('notes').insert({'title':..,'content':..,'user_id':..}).select().single()
-- Code: .from('notes').select().eq('user_id', uid).order('updated_at', ascending: false)
-- Code: .from('notes').update({'title':..,'content':..,'updated_at':..}).eq('id', id).eq('user_id', uid)
-- Code: .from('notes').delete().eq('id', id).eq('user_id', uid)
CREATE TABLE public.notes (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT        NOT NULL,
  content     TEXT        NOT NULL,
  user_id     TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ── photos ──────────────────────────────────────────────────────
-- Code: .from('photos').insert({'url':..,'user_id':..}).select().single()
-- Code: .from('photos').select().eq('user_id', uid).order('created_at', ascending: false)
-- Code: .from('photos').select('id, url').inFilter('id', ids).eq('user_id', uid)
-- Code: .from('photos').delete().inFilter('id', ids).eq('user_id', uid)
-- Code: .from('photos').select('url').eq('id', itemId).single()  ← shared feed
CREATE TABLE public.photos (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  url         TEXT        NOT NULL,
  user_id     TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ── friendships ─────────────────────────────────────────────────
-- QUAN TRỌNG: Tên FK constraint phải khớp với code Dart:
--   users!friendships_requester_id_fkey(*)
--   users!friendships_addressee_id_fkey(*)
--
-- Code: .from('friendships').insert({'requester_id':..,'addressee_id':..,'status':'pending'})
--       .select('*, requester:users!friendships_requester_id_fkey(*), addressee:users!friendships_addressee_id_fkey(*)')
-- Code: .from('friendships').select('*, requester:users!friendships_requester_id_fkey(*), addressee:users!friendships_addressee_id_fkey(*)')
--       .eq('addressee_id', uid).eq('status', 'pending')
-- Code: .from('friendships').update({'status':'accepted'}).eq('id', id).eq('addressee_id', uid)
-- Code: .from('friendships').delete().eq('id', id).eq('addressee_id', uid)
-- Code: .from('friendships').delete().eq('id', id).or('requester_id.eq.uid,addressee_id.eq.uid')
CREATE TABLE public.friendships (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id  TEXT        NOT NULL,
  addressee_id  TEXT        NOT NULL,
  status        TEXT        NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- FK với tên constraint cụ thể (Dart code dùng tên này để join)
  CONSTRAINT friendships_requester_id_fkey
    FOREIGN KEY (requester_id) REFERENCES public.users(uid) ON DELETE CASCADE,
  CONSTRAINT friendships_addressee_id_fkey
    FOREIGN KEY (addressee_id) REFERENCES public.users(uid) ON DELETE CASCADE,

  -- Mỗi cặp user chỉ có 1 friendship
  CONSTRAINT unique_friendship UNIQUE (requester_id, addressee_id)
);


-- ── shared_items ────────────────────────────────────────────────
-- QUAN TRỌNG: Tên FK constraint phải khớp với code Dart:
--   users!shared_items_owner_id_fkey(display_name, photo_url)
--
-- Code: .from('shared_items').insert({'owner_id':..,'shared_with_id':..,'item_type':..,'item_id':..})
-- Code: .from('shared_items').select('*, owner:users!shared_items_owner_id_fkey(display_name, photo_url)')
--       .eq('shared_with_id', uid).order('created_at', ascending: false).limit(50)
CREATE TABLE public.shared_items (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id        TEXT        NOT NULL,
  shared_with_id  TEXT        NOT NULL,
  item_type       TEXT        NOT NULL CHECK (item_type IN ('photo', 'note')),
  item_id         UUID        NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- FK với tên constraint cụ thể (Dart code dùng tên này để join)
  CONSTRAINT shared_items_owner_id_fkey
    FOREIGN KEY (owner_id) REFERENCES public.users(uid) ON DELETE CASCADE,
  CONSTRAINT shared_items_shared_with_id_fkey
    FOREIGN KEY (shared_with_id) REFERENCES public.users(uid) ON DELETE CASCADE
);


-- ── moments ─────────────────────────────────────────────────────
-- Code: .from('moments').insert({'user_id':..,'content':..,'image_url':..,'mood':..})
--       .select('*, user:users!moments_user_id_fkey(..), moment_reactions(*, user:users!moment_reactions_user_id_fkey(..))')
-- Code: .from('moments').select('*, user:users!moments_user_id_fkey(..), moment_reactions(..)')
--       .inFilter('user_id', friendIds).order('created_at', ascending: false).limit(50)
-- Code: .from('moments').delete().eq('id', id).eq('user_id', uid)
CREATE TABLE public.moments (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT        NOT NULL,
  content     TEXT,
  image_url   TEXT,
  mood        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT moments_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES public.users(uid) ON DELETE CASCADE
);


-- ── moment_reactions ────────────────────────────────────────────
-- Code: .from('moment_reactions').upsert({'moment_id':..,'user_id':..,'emoji':..}, onConflict: 'moment_id,user_id')
--       .select('*, user:users!moment_reactions_user_id_fkey(display_name, photo_url)')
CREATE TABLE public.moment_reactions (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  moment_id   UUID        NOT NULL REFERENCES public.moments(id) ON DELETE CASCADE,
  user_id     TEXT        NOT NULL,
  emoji       TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT moment_reactions_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES public.users(uid) ON DELETE CASCADE,

  -- Mỗi user chỉ 1 reaction per moment (upsert on conflict)
  CONSTRAINT unique_moment_reaction UNIQUE (moment_id, user_id)
);


-- ── documents ───────────────────────────────────────────────────
-- Code: .from('documents').insert({..}).select().single()
-- Code: .from('documents').select().eq('user_id', uid).order('created_at', ascending: false)
-- Code: .from('documents').delete().eq('id', id).eq('user_id', uid)
CREATE TABLE public.documents (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  file_name    TEXT        NOT NULL,
  file_url     TEXT        NOT NULL,
  file_type    TEXT        NOT NULL CHECK (file_type IN ('pdf', 'docx', 'txt', 'unknown')),
  file_size    INTEGER,
  text_content TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ── day_counters ────────────────────────────────────────────────
-- Code: .from('day_counters').insert({..}).select().single()
-- Code: .from('day_counters').select().eq('user_id', uid).order('created_at', ascending: false)
-- Code: .from('day_counters').update({..}).eq('id', id).eq('user_id', uid).select().single()
-- Code: .from('day_counters').delete().eq('id', id).eq('user_id', uid)
CREATE TABLE public.day_counters (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  title       TEXT        NOT NULL,
  target_date DATE        NOT NULL,
  emoji       TEXT        NOT NULL DEFAULT '❤️',
  color_hex   TEXT        NOT NULL DEFAULT 'FFD32F2F',
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ── finance_categories ──────────────────────────────────────────
-- Code: .from('finance_categories').select()
--       .or('is_default.eq.true,user_id.eq.uid')
-- Code: .from('finance_categories').insert({..}).select().single()
CREATE TABLE public.finance_categories (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT        REFERENCES public.users(uid) ON DELETE CASCADE,
  name        TEXT        NOT NULL,
  icon        TEXT        NOT NULL DEFAULT '📦',
  color       TEXT        NOT NULL DEFAULT 'FF9E9E9E',
  type        TEXT        NOT NULL CHECK (type IN ('income', 'expense')),
  is_default  BOOLEAN     NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ── transactions ────────────────────────────────────────────────
-- Code: .from('transactions').insert({..})
--       .select('*, category:finance_categories!transactions_category_id_fkey(name, icon, color)')
-- Code: .from('transactions').select('*, category:finance_categories!transactions_category_id_fkey(..)')
--       .eq('user_id', uid).gte('date', start).lt('date', end).order('date')
CREATE TABLE public.transactions (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  category_id UUID        NOT NULL,
  type        TEXT        NOT NULL CHECK (type IN ('income', 'expense')),
  amount      INTEGER     NOT NULL CHECK (amount > 0),
  note        TEXT,
  date        DATE        NOT NULL DEFAULT CURRENT_DATE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT transactions_category_id_fkey
    FOREIGN KEY (category_id) REFERENCES public.finance_categories(id) ON DELETE RESTRICT
);


-- ── budgets ─────────────────────────────────────────────────────
-- Code: .from('budgets').upsert({..}, onConflict: 'user_id,category_id,month,year')
--       .select('*, category:finance_categories!budgets_category_id_fkey(..)')
-- Code: .from('budgets').select('*, category:finance_categories!budgets_category_id_fkey(..)')
--       .eq('user_id', uid).eq('month', m).eq('year', y)
CREATE TABLE public.budgets (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  category_id UUID        NOT NULL,
  amount      INTEGER     NOT NULL CHECK (amount > 0),
  month       INTEGER     NOT NULL CHECK (month BETWEEN 1 AND 12),
  year        INTEGER     NOT NULL CHECK (year >= 2020),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT budgets_category_id_fkey
    FOREIGN KEY (category_id) REFERENCES public.finance_categories(id) ON DELETE CASCADE,

  CONSTRAINT unique_budget UNIQUE (user_id, category_id, month, year)
);


-- ================================================================
-- 2. INDEXES (tối ưu các query trong code)
-- ================================================================

-- notes: .select().eq('user_id', uid).order('updated_at')
CREATE INDEX idx_notes_user_id          ON public.notes(user_id);
CREATE INDEX idx_notes_updated_at       ON public.notes(updated_at DESC);

-- photos: .select().eq('user_id', uid).order('created_at')
CREATE INDEX idx_photos_user_id         ON public.photos(user_id);
CREATE INDEX idx_photos_created_at      ON public.photos(created_at DESC);

-- friendships: .eq('addressee_id', uid).eq('status', 'pending')
-- friendships: .eq('status', 'accepted').or('requester_id.eq.uid,addressee_id.eq.uid')
CREATE INDEX idx_friendships_requester  ON public.friendships(requester_id);
CREATE INDEX idx_friendships_addressee  ON public.friendships(addressee_id);
CREATE INDEX idx_friendships_status     ON public.friendships(status);

-- shared_items: .eq('shared_with_id', uid).order('created_at')
CREATE INDEX idx_shared_items_owner     ON public.shared_items(owner_id);
CREATE INDEX idx_shared_items_shared    ON public.shared_items(shared_with_id);
CREATE INDEX idx_shared_items_type_id   ON public.shared_items(item_type, item_id);

-- moments: .inFilter('user_id', friendIds).order('created_at')
CREATE INDEX idx_moments_user_id        ON public.moments(user_id);
CREATE INDEX idx_moments_created_at     ON public.moments(created_at DESC);

-- moment_reactions: join by moment_id
CREATE INDEX idx_moment_reactions_moment ON public.moment_reactions(moment_id);
CREATE INDEX idx_moment_reactions_user   ON public.moment_reactions(user_id);

-- documents: .eq('user_id', uid).order('created_at')
CREATE INDEX idx_documents_user         ON public.documents(user_id);
CREATE INDEX idx_documents_created      ON public.documents(created_at DESC);

-- day_counters: .eq('user_id', uid).order('created_at')
CREATE INDEX idx_day_counters_user      ON public.day_counters(user_id);
CREATE INDEX idx_day_counters_created   ON public.day_counters(created_at DESC);

-- finance_categories
CREATE INDEX idx_finance_cat_user       ON public.finance_categories(user_id);
CREATE INDEX idx_finance_cat_type       ON public.finance_categories(type);
CREATE INDEX idx_finance_cat_default    ON public.finance_categories(is_default);

-- transactions: .eq('user_id', uid).gte('date', start).lt('date', end)
CREATE INDEX idx_transactions_user      ON public.transactions(user_id);
CREATE INDEX idx_transactions_date      ON public.transactions(date DESC);
CREATE INDEX idx_transactions_category  ON public.transactions(category_id);
CREATE INDEX idx_transactions_type      ON public.transactions(type);
CREATE INDEX idx_transactions_user_date ON public.transactions(user_id, date);

-- budgets: .eq('user_id', uid).eq('month', m).eq('year', y)
CREATE INDEX idx_budgets_user_period    ON public.budgets(user_id, month, year);

-- users: .or('email.ilike.%q%,display_name.ilike.%q%')
-- (trigram index cho tìm kiếm ILIKE nhanh hơn)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_users_email_trgm       ON public.users USING gin (email gin_trgm_ops);
CREATE INDEX idx_users_display_name_trgm ON public.users USING gin (display_name gin_trgm_ops);


-- ================================================================
-- 3. AUTO-UPDATE updated_at TRIGGER
-- ================================================================

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_transactions_updated_at
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


-- ================================================================
-- 4. ROW LEVEL SECURITY — TẮT (vì dùng Firebase Auth)
-- ================================================================
-- App dùng Firebase Auth + Supabase anon key.
-- auth.uid() = NULL → RLS dùng auth.uid() sẽ block mọi thứ.
-- → Tắt RLS, để anon key truy cập tự do.
-- → Khi tích hợp Supabase Auth sau này, bật lại và thêm policy.

ALTER TABLE public.users                DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes                DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos               DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships          DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_items         DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.moments              DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.moment_reactions     DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents            DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.day_counters         DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.finance_categories   DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions         DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets              DISABLE ROW LEVEL SECURITY;


-- ================================================================
-- 5. STORAGE BUCKETS
-- ================================================================

-- Tạo bucket "photos" (public, ai cũng xem được URL)
-- Code: storage.from('photos').upload(fileName, file)
-- Code: storage.from('photos').getPublicUrl(fileName)
-- Code: storage.from('photos').remove(storagePaths)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'photos',
  'photos',
  true,
  10485760,  -- 10MB max
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Tạo bucket "avatars" (public)
-- Code: storage.from('avatars').upload(fileName, file, fileOptions: FileOptions(upsert: true))
-- Code: storage.from('avatars').getPublicUrl(fileName)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880,  -- 5MB max
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Tạo bucket "moments" (public)
-- Code: storage.from('moments').upload(fileName, file)
-- Code: storage.from('moments').getPublicUrl(fileName)
-- Code: storage.from('moments').remove([storagePath])
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'moments',
  'moments',
  true,
  10485760,  -- 10MB max
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;


-- ================================================================
-- 6. STORAGE POLICIES (mở hoàn toàn vì dùng Firebase Auth)
-- ================================================================

-- Photos bucket
DROP POLICY IF EXISTS "photos_select" ON storage.objects;
DROP POLICY IF EXISTS "photos_insert" ON storage.objects;
DROP POLICY IF EXISTS "photos_delete" ON storage.objects;
CREATE POLICY "photos_select" ON storage.objects FOR SELECT USING (bucket_id = 'photos');
CREATE POLICY "photos_insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'photos');
CREATE POLICY "photos_delete" ON storage.objects FOR DELETE USING (bucket_id = 'photos');

-- Avatars bucket
DROP POLICY IF EXISTS "avatars_select" ON storage.objects;
DROP POLICY IF EXISTS "avatars_insert" ON storage.objects;
DROP POLICY IF EXISTS "avatars_update" ON storage.objects;
DROP POLICY IF EXISTS "avatars_delete" ON storage.objects;
CREATE POLICY "avatars_select" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "avatars_insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars');
CREATE POLICY "avatars_update" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars');
CREATE POLICY "avatars_delete" ON storage.objects FOR DELETE USING (bucket_id = 'avatars');

-- Documents bucket
DROP POLICY IF EXISTS "documents_select" ON storage.objects;
DROP POLICY IF EXISTS "documents_insert" ON storage.objects;
DROP POLICY IF EXISTS "documents_delete" ON storage.objects;
CREATE POLICY "documents_select" ON storage.objects FOR SELECT USING (bucket_id = 'documents');
CREATE POLICY "documents_insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'documents');
CREATE POLICY "documents_delete" ON storage.objects FOR DELETE USING (bucket_id = 'documents');

-- Moments bucket
DROP POLICY IF EXISTS "moments_select" ON storage.objects;
DROP POLICY IF EXISTS "moments_insert" ON storage.objects;
DROP POLICY IF EXISTS "moments_delete" ON storage.objects;
CREATE POLICY "moments_select" ON storage.objects FOR SELECT USING (bucket_id = 'moments');
CREATE POLICY "moments_insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'moments');
CREATE POLICY "moments_delete" ON storage.objects FOR DELETE USING (bucket_id = 'moments');


-- ================================================================
-- 7. SEED DATA — Danh mục tài chính mặc định
-- ================================================================

-- Chi tiêu (expense)
INSERT INTO public.finance_categories (name, icon, color, type, is_default) VALUES
  ('An uong',       '🍜', 'FFFF7043', 'expense', true),
  ('Di chuyen',     '🚕', 'FF42A5F5', 'expense', true),
  ('Mua sam',       '🛍️', 'FFAB47BC', 'expense', true),
  ('Hoa don',       '🧾', 'FFFFCA28', 'expense', true),
  ('Suc khoe',      '💊', 'FF66BB6A', 'expense', true),
  ('Giai tri',      '🎮', 'FF7E57C2', 'expense', true),
  ('Giao duc',      '📚', 'FF5C6BC0', 'expense', true),
  ('Nha cua',       '🏠', 'FF8D6E63', 'expense', true),
  ('Qua tang',      '🎁', 'FFEC407A', 'expense', true),
  ('Khac',          '📦', 'FF9E9E9E', 'expense', true);

-- Thu nhập (income)
INSERT INTO public.finance_categories (name, icon, color, type, is_default) VALUES
  ('Luong',         '💰', 'FF4CAF50', 'income', true),
  ('Thuong',        '🎉', 'FFFFB74D', 'income', true),
  ('Dau tu',        '📈', 'FF29B6F6', 'income', true),
  ('Freelance',     '💻', 'FF26A69A', 'income', true),
  ('Thu nhap khac', '💵', 'FF9E9E9E', 'income', true);


-- ── wishes ──────────────────────────────────────────────────────
-- Code: .from('wishes').select().eq('user_id', uid).order('created_at', ascending: false)
-- Code: .from('wishes').insert({..}).select().single()
-- Code: .from('wishes').update({..}).eq('id', id).eq('user_id', uid).select().single()
-- Code: .from('wishes').delete().eq('id', id).eq('user_id', uid)
CREATE TABLE public.wishes (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  title           TEXT        NOT NULL,
  description     TEXT,
  emoji           TEXT        NOT NULL DEFAULT '⭐',
  is_completed    BOOLEAN     NOT NULL DEFAULT false,
  completed_at    TIMESTAMPTZ,
  completion_note TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_wishes_user_id    ON public.wishes(user_id);
CREATE INDEX idx_wishes_created_at ON public.wishes(created_at DESC);

CREATE TRIGGER trigger_wishes_updated_at
  BEFORE UPDATE ON public.wishes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


-- ── qa_answers ─────────────────────────────────────────────────
-- Code: .from('qa_answers').select().eq('friendship_id', fId).eq('question_date', dateStr)
-- Code: .from('qa_answers').insert({..}).select().single()
-- Code: .from('qa_answers').select().eq('friendship_id', fId).order('question_date', ascending: false)
CREATE TABLE public.qa_answers (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         TEXT        NOT NULL REFERENCES public.users(uid) ON DELETE CASCADE,
  friendship_id   UUID        NOT NULL REFERENCES public.friendships(id) ON DELETE CASCADE,
  question_index  INTEGER     NOT NULL,
  question_date   DATE        NOT NULL,
  answer_text     TEXT        NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT unique_qa_answer UNIQUE (user_id, friendship_id, question_date)
);

CREATE INDEX idx_qa_answers_user       ON public.qa_answers(user_id);
CREATE INDEX idx_qa_answers_friendship ON public.qa_answers(friendship_id);
CREATE INDEX idx_qa_answers_date       ON public.qa_answers(question_date DESC);


-- ── love_letters ───────────────────────────────────────────────
-- Code: .from('love_letters').select('*, recipient:users!love_letters_recipient_id_fkey(display_name, photo_url)')
--       .eq('sender_id', uid).order('created_at', ascending: false)
-- Code: .from('love_letters').select('*, sender:users!love_letters_sender_id_fkey(display_name, photo_url)')
--       .eq('recipient_id', uid).order('delivery_date', ascending: false)
-- Code: .from('love_letters').insert({..}).select().single()
-- Code: .from('love_letters').update({..}).eq('id', id).eq('recipient_id', uid).select().single()
CREATE TABLE public.love_letters (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id       TEXT        NOT NULL,
  recipient_id    TEXT        NOT NULL,
  title           TEXT        NOT NULL,
  content         TEXT        NOT NULL,
  delivery_date   DATE        NOT NULL,
  is_read         BOOLEAN     NOT NULL DEFAULT false,
  read_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT love_letters_sender_id_fkey
    FOREIGN KEY (sender_id) REFERENCES public.users(uid) ON DELETE CASCADE,
  CONSTRAINT love_letters_recipient_id_fkey
    FOREIGN KEY (recipient_id) REFERENCES public.users(uid) ON DELETE CASCADE
);

CREATE INDEX idx_love_letters_sender    ON public.love_letters(sender_id);
CREATE INDEX idx_love_letters_recipient ON public.love_letters(recipient_id);
CREATE INDEX idx_love_letters_delivery  ON public.love_letters(delivery_date);
CREATE INDEX idx_love_letters_created   ON public.love_letters(created_at DESC);

ALTER TABLE public.wishes               DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.qa_answers           DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.love_letters         DISABLE ROW LEVEL SECURITY;


-- ================================================================
-- DONE! Tất cả bảng, index, trigger, storage đã sẵn sàng.
-- ================================================================
--
-- Tạo bucket "documents"
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'documents',
  'documents',
  true,
  52428800,  -- 50MB max
  ARRAY['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain']
)
ON CONFLICT (id) DO NOTHING;


-- BẢNG              │ DÙNG CHO
-- ──────────────────┼──────────────────────────────────
-- users             │ Profile, tìm kiếm user, join FK
-- notes             │ CRUD ghi chú
-- photos            │ Upload/xem/xóa ảnh
-- friendships       │ Gửi/nhận/chấp nhận/hủy kết bạn
-- shared_items      │ Chia sẻ ảnh/note với bạn bè
-- moments           │ Chia sẻ tâm trạng/ảnh (Locket-style)
-- moment_reactions  │ React emoji cho moments
-- documents         │ Tài liệu PDF/Word/TXT upload
-- day_counters      │ Đếm ngày (yêu, sinh nhật, sự kiện)
-- finance_categories│ Danh mục thu/chi (default + custom)
-- transactions      │ Giao dịch thu nhập/chi tiêu
-- budgets           │ Ngân sách theo tháng/danh mục
--
-- STORAGE        │ DÙNG CHO
-- ───────────────┼──────────────────────────────────
-- photos         │ File ảnh upload (path: {uid}/{timestamp}_{filename})
-- avatars        │ Avatar profile (path: {uid}/avatar_{timestamp}_{filename})
-- moments        │ Ảnh moment (path: {uid}/moment_{timestamp}_{filename})
-- documents      │ File tài liệu (path: {uid}/{timestamp}_{filename})
--
-- ================================================================
