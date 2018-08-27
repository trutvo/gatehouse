defmodule Gatehouse.AdministrationManager do
    import Ecto.Changeset, only: [put_change: 3]
    require Logger
    import Ecto.Query, only: [from: 2]
    alias Gatehouse.Principal
    alias Gatehouse.Role
    alias Gatehouse.Repo

    defp map_principal(p) do
        %{ id: p.id, 
            email: p.email
         } 
    end

    def get_principals() do
        Repo.all(Principal) |> Enum.map(&map_principal/1)
    end

    def is_admin(principal) do
        Enum.find(principal.roles, &Role.is_admin_role/1)
    end

    def update_password(principal_id, password) do
        Repo.transaction(fn ->
            principal = Repo.get_by(Principal, id: principal_id)
            Ecto.Changeset.change(principal) 
                |> put_change(:password, password)
                |> put_change(:crypted_password, Principal.pwhash(password))
                |> Repo.update()
        end)
    end

    def update_pricipal_to_role_relation(current_principal, principal_id, role_id, active) do
        Repo.transaction(fn ->
            role = Repo.get_by(Role, id: role_id)
            if Role.is_admin_role(role.name) 
                and String.to_integer(principal_id) == current_principal.id do
                Logger.info "admin can not change his own admin privileges!"
            else
                principal = Repo.get_by(Principal, id: principal_id)
                principal = principal |> Repo.preload(:roles)
                roles = if active do
                    Enum.concat(principal.roles, [role])
                else
                    Enum.filter(principal.roles, fn r -> r.id != role.id end)
                end
                changeset = Ecto.Changeset.change(principal) |> Ecto.Changeset.put_assoc(:roles, roles)
                Repo.update!(changeset)
            end
        end)
    end

    def create_principal(email) do
        password = generate_random_password()
        changeset = Principal.changeset(%Principal{}, %{email: email, password: password})
        {:ok, principal} = changeset
            |> put_change(:crypted_password, Principal.pwhash(changeset.params["password"]))
            |> Repo.insert()
        map_principal(principal) |> Map.put("password", password)    
    end

    def principal_with_roles_selection_list(id) do
        principal = map_principal(Repo.get_by(Principal, id: id))
        roles = Repo.all(from r in Role, preload: [:principals])
                    |> Enum.map(fn r -> %{id: r.id, 
                                name: r.name, 
                                active: r.principals |> Enum.count(fn p -> p.id == String.to_integer(id) end) > 0 } 
                    end)
        Map.put(principal, :roles_selection_list, roles) 
    end

    def generate_random_password(length \\ 16), do: RandomBytes.base62(length)

end