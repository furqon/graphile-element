CREATE EXTENSION IF NOT EXISTS "pgcrypto"; 
CREATE EXTENSION IF NOT EXISTS "citext"; 

-- schema
CREATE SCHEMA auth_public; 
CREATE SCHEMA auth_private;

-- user accessing graphql
CREATE ROLE auth_postgraphile LOGIN PASSWORD 'password';

CREATE ROLE auth_anonymous;
CREATE ROLE auth_authenticated; 

GRANT auth_authenticated TO auth_postgraphile;
GRANT USAGE ON SCHEMA auth_public TO auth_anonymous, auth_authenticated; 

CREATE TABLE auth_public.user ( 
  id              serial primary key, 
  first_name      text not null check (char_length(first_name) < 80), 
  last_name       text check (char_length(last_name) < 80), 
  created_at      timestamptz default now() 
);
CREATE TABLE auth_private.user_account ( 
  user_id         integer primary key references auth_public.user(id) on delete cascade, 
  email           citext not null unique, 
  password_hash   text not null 
);
-- register user
CREATE FUNCTION auth_public.register_user( 
  first_name  text, 
  last_name   text, 
  email       text, 
  password    text 
) RETURNS auth_public.user AS $$ 
DECLARE 
  new_user auth_public.user; 
BEGIN 
  INSERT INTO auth_public.user (first_name, last_name) values 
    (first_name, last_name) 
    returning * INTO new_user; 
  INSERT INTO auth_private.user_account (user_id, email, password_hash) values 
    (new_user.id, lower(email), crypt(password, gen_salt('bf'))); 
  return new_user; 
END; 
$$ language plpgsql strict security definer;
-- grant anon to add user
GRANT EXECUTE ON FUNCTION auth_public.register_user(text, text, text, text) TO auth_anonymous; 
-- add user
select auth_public.register_user('Admin','User','admin@mail.com','password');

-- type jwt
CREATE TYPE auth_public.jwt as ( 
  role    text, 
  user_id integer 
);

-- login
CREATE FUNCTION auth_public.login ( 
  email text, 
  password text 
) returns auth_public.jwt as $$ 
DECLARE 
  account auth_private.user_account; 
BEGIN 
  SELECT a.* INTO account 
  FROM auth_private.user_account as a 
  WHERE a.email = lower($1); 
  if account.password_hash = crypt(password, account.password_hash) then 
    return ('auth_authenticated', account.user_id)::auth_public.jwt; 
  else 
    return null; 
  end if; 
END; 
$$ language plpgsql strict security definer;
--grant
GRANT EXECUTE ON FUNCTION auth_public.login(text, text) TO auth_anonymous; 

-- ROLE
CREATE TABLE auth_public.role ( 
  id              serial primary key, 
  name            citext not null unique,
  created_at timestamptz DEFAULT now()
);
insert into auth_public.role (name) values ('admin');
CREATE TABLE auth_public.user_role ( 
  user_id         integer references auth_public.user(id) on delete cascade, 
  role_id         integer references auth_public.role(id) on delete cascade
);
CREATE INDEX ON auth_public.user_role(role_id);
CREATE INDEX ON auth_public.user_role(user_id);
insert into auth_public.user_role (user_id, role_id) values (1,1);
-- user
GRANT SELECT ON TABLE auth_public.user TO auth_anonymous, auth_authenticated; 

CREATE FUNCTION auth_public.current_user_id() RETURNS INTEGER AS $$
  SELECT current_setting('jwt.claims.user_id', true)::integer;
$$ LANGUAGE SQL STABLE;

CREATE FUNCTION auth_public.current_user() RETURNS auth_public.user AS $$ 
  SELECT * 
  FROM auth_public.user 
  WHERE id = auth_public.current_user_id()
$$ language sql stable;

-- current role
CREATE OR REPLACE FUNCTION auth_public.current_role()
RETURNS TABLE (
  id int, 
  name citext
)
LANGUAGE plpgsql stable AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.name
    FROM auth_public.role a 
      JOIN auth_public.user_role b on b.role_id=a.id 
      JOIN auth_public.user c on c.id=b.user_id
      WHERE c.id = auth_public.current_user_id();
END;
$$;
-- granting
GRANT EXECUTE ON FUNCTION auth_public.current_role() TO auth_authenticated; 
GRANT SELECT ON TABLE auth_public.role TO auth_authenticated; 
GRANT SELECT ON TABLE auth_public.user_role TO auth_authenticated; 