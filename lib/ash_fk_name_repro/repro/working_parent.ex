defmodule AshFkNameRepro.Repro.WorkingParent do
  @moduledoc "Mirror of `Parent`; its child sets an explicit FK name, so everything works."

  use Ash.Resource,
    domain: AshFkNameRepro.Repro,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "working_parents"
    repo AshFkNameRepro.Repo
  end

  actions do
    defaults [:read, :create, :destroy]
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    has_many :children, AshFkNameRepro.Repro.WorkingChild do
      destination_attribute :parent_ref
    end
  end
end
