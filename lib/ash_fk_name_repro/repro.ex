defmodule AshFkNameRepro.Repro do
  use Ash.Domain, otp_app: :ash_fk_name_repro

  resources do
    resource AshFkNameRepro.Repro.Parent
    resource AshFkNameRepro.Repro.Child
    resource AshFkNameRepro.Repro.WorkingParent
    resource AshFkNameRepro.Repro.WorkingChild
  end
end
