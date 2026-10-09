defmodule AshFkNameRepro.Repro.Child do
  use Ash.Resource,
    domain: AshFkNameRepro.Repro,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "children"
    repo AshFkNameRepro.Repo

    references do
      reference :parent, on_delete: :restrict
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
    belongs_to :parent, AshFkNameRepro.Repro.Parent do
      source_attribute :parent_ref
      define_attribute? false
    end
  end
end
