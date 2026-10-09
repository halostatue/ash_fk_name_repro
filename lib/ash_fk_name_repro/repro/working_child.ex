defmodule AshFkNameRepro.Repro.WorkingChild do
  @moduledoc """
  Mirror of `Child`, but the reference sets `name:` to the attribute-based
  default that ash_postgres registers at runtime, so the migration and the
  runtime constraint registration agree.
  """

  use Ash.Resource,
    domain: AshFkNameRepro.Repro,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "working_children"
    repo AshFkNameRepro.Repo

    references do
      reference :parent, on_delete: :restrict, name: "working_children_parent_ref_fkey"
    end
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:parent_ref]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :parent_ref, :uuid do
      allow_nil? false
      public? true
      source :ref_parent
    end
  end

  relationships do
    belongs_to :parent, AshFkNameRepro.Repro.WorkingParent do
      source_attribute :parent_ref
      define_attribute? false
    end
  end
end
