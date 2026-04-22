# Supabase trong Project

## Vai tro

- **Database** (PostgreSQL): Luu tru users, notes, photos, friendships, moments, transactions, budgets, day_counters
- **Storage**: Luu file anh (photos, avatars, moments)
- **Auth**: Hien tai KHONG dung Supabase Auth, dung Firebase Auth. RLS da tat.

## Cau hinh

Moi flavor co Supabase config rieng:

```
development/lib/config/app_config.dart   → Supabase dev URL + key
production/lib/config/app_config.dart    → Supabase prod URL + key
```

Khoi tao trong `main.dart`:

```dart
await Supabase.initialize(
  url: AppConfig.supabaseUrl,
  anonKey: AppConfig.supabaseAnonKey,
);
```

## Schema

File `supabase_setup.sql` o root chua toan bo schema.
Copy vao Supabase Dashboard → SQL Editor → Run.

### Cac bang hien co

| Bang               | Chuc nang                              |
|--------------------|----------------------------------------|
| users              | Profile user (PK = Firebase UID)       |
| notes              | Ghi chu CRUD                           |
| photos             | Anh upload                             |
| friendships        | Ket ban (pending/accepted)             |
| shared_items       | Chia se anh/note voi ban be            |
| moments            | Chia se tam trang (Locket-style)       |
| moment_reactions   | React emoji cho moments                |
| finance_categories | Danh muc thu/chi (default + custom)    |
| transactions       | Giao dich thu nhap/chi tieu            |
| budgets            | Ngan sach theo thang/danh muc          |
| day_counters       | Dem ngay (yeu, sinh nhat, su kien)     |

### Storage buckets

| Bucket   | Dung cho                      | Max size |
|----------|-------------------------------|----------|
| photos   | Anh upload tu photo picker    | 10MB     |
| avatars  | Avatar profile                | 5MB      |
| moments  | Anh trong moment              | 10MB     |

## Pattern truy van

```dart
// SELECT
final response = await _supabaseClient
    .from('notes')
    .select()
    .eq('user_id', user.uid)
    .order('updated_at', ascending: false);

// INSERT
final response = await _supabaseClient
    .from('notes')
    .insert({'title': title, 'content': content, 'user_id': user.uid})
    .select()
    .single();

// UPDATE
final response = await _supabaseClient
    .from('notes')
    .update({'title': title})
    .eq('id', id)
    .eq('user_id', user.uid)
    .select()
    .single();

// DELETE
await _supabaseClient
    .from('notes')
    .delete()
    .eq('id', id)
    .eq('user_id', user.uid);

// UPSERT (insert hoac update neu da ton tai)
await _supabaseClient
    .from('users')
    .upsert(user.toJson(), onConflict: 'uid');

// JOIN (qua FK constraint)
.select('*, category:finance_categories!transactions_category_id_fkey(name, icon, color)')

// FILTER
.or('requester_id.eq.$uid,addressee_id.eq.$uid')
.inFilter('user_id', friendIds)
.gte('date', startDate)
.lt('date', endDate)
```

## Storage operations

```dart
// Upload
await _supabaseClient.storage.from('photos').upload(fileName, file);

// Get public URL
final url = _supabaseClient.storage.from('photos').getPublicUrl(fileName);

// Delete
await _supabaseClient.storage.from('photos').remove([storagePath]);
```

## Quy tac quan trong

- Khi them feature moi co lien quan den Supabase, PHAI cap nhat file `supabase_setup.sql`
- User ID trong Supabase la Firebase UID (TEXT), khong phai UUID
- RLS dang TAT vi dung Firebase Auth (auth.uid() = NULL)
