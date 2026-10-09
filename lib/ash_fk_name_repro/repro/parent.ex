defmodule AshFkNameRepro.Repro.Parent do
  use Ash.Resource,
    domain: AshFkNameRepro.Repro,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "parents"
    repo AshFkNameRepro.Repo
  end

  actions do
    defaults [:read, :create, :destroy]
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    has_many :children, AshFkNameRepro.Repro.Child do
      destination_attribute :parent_ref
    end
  end
end
