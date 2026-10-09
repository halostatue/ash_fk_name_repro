defmodule AshFkNameRepro.FkConstraintNameTest do
  use AshFkNameRepro.DataCase

  alias AshFkNameRepro.Repro.{Child, Parent, WorkingChild, WorkingParent}

  defp fk_names(table) do
    %{rows: rows} =
      Repo.query!(
        """
        SELECT conname FROM pg_constraint
        WHERE conrelid = $1::text::regclass AND contype = 'f'
        """,
        [table]
      )

    List.flatten(rows)
  end

  describe "default FK name (no `name:` on the reference)" do
    test "migration names the FK after the column (source)" do
      assert fk_names("children") == ["children_ref_parent_fkey"]
    end

    test "creating a child with a missing parent returns Ash.Error.Invalid" do
      assert {:error, %Ash.Error.Invalid{}} =
               Ash.create(Child, %{parent_ref: Ash.UUID.generate()})
    end

    test "destroying a parent that still has children returns Ash.Error.Invalid" do
      parent = Ash.create!(Parent, %{})
      Ash.create!(Child, %{parent_ref: parent.id})

      assert {:error, %Ash.Error.Invalid{}} = Ash.destroy(parent)
    end
  end

  describe "explicit `name:` on the reference (workaround)" do
    test "migration uses the explicit name" do
      assert fk_names("working_children") == ["working_children_parent_ref_fkey"]
    end

    test "creating a child with a missing parent returns Ash.Error.Invalid" do
      assert {:error, %Ash.Error.Invalid{}} =
               Ash.create(WorkingChild, %{parent_ref: Ash.UUID.generate()})
    end

    test "destroying a parent that still has children returns Ash.Error.Invalid" do
      parent = Ash.create!(WorkingParent, %{})
      Ash.create!(WorkingChild, %{parent_ref: parent.id})

      assert {:error, %Ash.Error.Invalid{}} = Ash.destroy(parent)
    end
  end
end
