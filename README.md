# Mismatched Postgres and Ash FK constraint names

See: ash-project/ash_postgres#885

When the attribute behind a `belongs_to` relationship has a `source` column
name that differs from the attribute name, two different names are derived for
that constraint depending on the context.

```elixir
postgres do
  table "children"
  repo AshFkNameRepro.Repo

  references do
    reference :parent, on_delete: :restrict
  end
end

attributes do
  # …
  attribute :parent_ref, :uuid do
    allow_nil? false
    public? true
    source :ref_parent
  end
end

relationships do
  belongs_to :parent, AshFkNameRepro.Repro.Parent do
    source_attribute :parent_ref
    define_attribute? false
  end
end
```

The migration generator uses the _source column name_ for the generated
constraint name (`children_ref_parent_fkey`). When checking for a violation of
this constraint, AshPostgres.DataLayer registers the constraint name based on
the _attribute name_ (`children_parent_ref_fkey`). Because Ecto can't match
`children_parent_ref_fkey` against `children_ref_parent_fkey` it raises
`Ecto.ConstraintError`, which is wrapped as `Ash.Error.Unknown` instead of the
`Ash.Error.Invalid` changeset error.

The workaround is to add a _name_ to the reference which matches the expected
name:

```elixir
postgres do
  references do
    reference :parent, on_delete: :restrict, name: "children_parent_ref_fkey"
  end
end
```

## Reproduction

This repo contains parent/child resources that show the issue
(`AshFkNameRepro.Repro.Parent` and `AshFkNameRepro.Repro.Child`) and the
workaround (`AshFkNameRepro.Repro.WorkingParent` and
`AshFkNameRepro.Repro.WorkingChild`).

There are six tests in `test/fk_constraint_name_test.exs`, three for each of
the broken and working pairs of resources. Each describe group has tests that
assert:

1. the generated foreign key constraint matches the expected name
2. a child with a non-existent parent returns `Ash.Error.Invalid` and not
   `Ash.Error.Unknown`.
3. a parent destroyed with existing children returns `Ash.Error.Invalid` and
   not `Ash.Error.Unknown`.

This should happen on any version of PostgreSQL but was verified on 18 and has
been verified with the latest versions of Ash (3.34.6) and AshPostgres
(2.14.5).

## Possible Investigative Routes

Claude suggests that the fix is to ensure that the runtime paths which
register constraint names look up the attribute and use its derived `source`
for the default name.

- `add_my_foreign_key_constraints/3`:
  `Ash.Resource.Info.attribute(resource, relationship.source_attribute).source`
- `add_related_foreign_key_constraints/3`:
  `Ash.Resource.Info.attribute(source, source_attribute).source`.
