# Supabase Security Configuration

## Row-Level Security (RLS) Policies

This document outlines the recommended RLS policies to secure data in your Firebase Cloud Firestore database.

### Prerequisite
Ensure RLS is enabled on all tables in Supabase. RLS can be enabled in the Supabase Dashboard:
- Navigate to **Authentication** → **Policies**
- Enable RLS for each table

### RLS Policies

#### 1. **users** table
```sql
-- Enable SELECT for authenticated users to see their own profile
CREATE POLICY "Users can view their own profile"
ON public.users
FOR SELECT
USING (auth.uid() = id);

-- Enable UPDATE for authenticated users to update their own profile
CREATE POLICY "Users can update their own profile"
ON public.users
FOR UPDATE
USING (auth.uid() = id);
```

#### 2. **standing_orders** table
```sql
-- Enable SELECT for authenticated users
CREATE POLICY "Users can view standing orders"
ON public.standing_orders
FOR SELECT
USING (auth.uid() = user_id);

-- Enable INSERT for authenticated users
CREATE POLICY "Users can create standing orders"
ON public.standing_orders
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Enable UPDATE for authenticated users to update their own orders
CREATE POLICY "Users can update their own standing orders"
ON public.standing_orders
FOR UPDATE
USING (auth.uid() = user_id);

-- Enable DELETE for authenticated users to delete their own orders
CREATE POLICY "Users can delete their own standing orders"
ON public.standing_orders
FOR DELETE
USING (auth.uid() = user_id);
```

#### 3. **standing_orders_documents** table
```sql
-- Enable SELECT for authenticated users
CREATE POLICY "Users can view their documents"
ON public.standing_orders_documents
FOR SELECT
USING (auth.uid() = user_id);

-- Enable INSERT for authenticated users
CREATE POLICY "Users can upload documents"
ON public.standing_orders_documents
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Enable UPDATE for authenticated users
CREATE POLICY "Users can update their documents"
ON public.standing_orders_documents
FOR UPDATE
USING (auth.uid() = user_id);

-- Enable DELETE for authenticated users
CREATE POLICY "Users can delete their documents"
ON public.standing_orders_documents
FOR DELETE
USING (auth.uid() = user_id);
```

#### 4. **appointments** table
```sql
-- Enable SELECT for authenticated users
CREATE POLICY "Users can view appointments"
ON public.appointments
FOR SELECT
USING (auth.uid() = user_id);

-- Enable INSERT for authenticated users
CREATE POLICY "Users can create appointments"
ON public.appointments
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Enable UPDATE for authenticated users
CREATE POLICY "Users can update their appointments"
ON public.appointments
FOR UPDATE
USING (auth.uid() = user_id);

-- Enable DELETE for authenticated users
CREATE POLICY "Users can delete their appointments"
ON public.appointments
FOR DELETE
USING (auth.uid() = user_id);
```

#### 5. **counseling_cases** table
```sql
-- Enable SELECT for authenticated users
CREATE POLICY "Users can view counseling cases"
ON public.counseling_cases
FOR SELECT
USING (auth.uid() = user_id);

-- Enable INSERT for authenticated users
CREATE POLICY "Users can create counseling cases"
ON public.counseling_cases
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Enable UPDATE for authenticated users
CREATE POLICY "Users can update their cases"
ON public.counseling_cases
FOR UPDATE
USING (auth.uid() = user_id);

-- Enable DELETE for authenticated users
CREATE POLICY "Users can delete their cases"
ON public.counseling_cases
FOR DELETE
USING (auth.uid() = user_id);
```

#### 6. **tasks** table
```sql
-- Enable SELECT for authenticated users
CREATE POLICY "Users can view tasks"
ON public.tasks
FOR SELECT
USING (auth.uid() = user_id);

-- Enable INSERT for authenticated users
CREATE POLICY "Users can create tasks"
ON public.tasks
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Enable UPDATE for authenticated users
CREATE POLICY "Users can update their tasks"
ON public.tasks
FOR UPDATE
USING (auth.uid() = user_id);

-- Enable DELETE for authenticated users
CREATE POLICY "Users can delete their tasks"
ON public.tasks
FOR DELETE
USING (auth.uid() = user_id);
```

### Implementation Steps

1. **Log in to Supabase Dashboard**
2. **Select your project**
3. **Navigate to SQL Editor** (or use the UI-based policy editor)
4. **Run each policy SQL statement** for your tables
5. **Verify** RLS is enabled on each table under **Authentication → Policies**

### Testing

Test RLS policies with:

```dart
// Example: Only authenticated users with matching user_id can read data
final response = await supabase
    .from('standing_orders')
    .select()
    .eq('user_id', currentUserId)
    .execute();

if (response.error != null) {
  print('RLS Policy denied access: ${response.error}');
} else {
  print('Access granted: ${response.data}');
}
```

### Security Best Practices

1. **Always use `auth.uid()`** in RLS policies to ensure user isolation
2. **Test policies** with different user accounts
3. **Audit logs** in Supabase to monitor access patterns
4. **Keep policies updated** as your data model evolves
5. **Use anon key** only for public data (if any)
6. **Use service_role key** only in trusted backend environments

### Additional Resources

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Row Security](https://www.postgresql.org/docs/current/sql-createpolicy.html)
