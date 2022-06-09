defmodule GenericRepo do
  @moduledoc """
  Base functionality for Repos. Import only what you need.

  Use (ha!) like so:

  defmodule YourApp.Wombats.Repo do
    use GenericRepo, schema: YourApp.Wombats.Wombat
    # ....
  end

  OR you can cherry-pick specific methods:
    use GenericRepo, schema: Worksheet.Wombats.Wombat, only: [:all, :one]

  OR you can pick all but a few methods:
    use GenericRepo, schema: Worksheet.Wombats.Wombat, except: [:all, :one]

  If you provide both `only` and `except` keys, we first grab the "only" methods
  and then run "except" over them. I don't believe there are cases where you
  want to include both keys.

  If you include a method that doesn't exist, it's just ignored.
  There exists a `preloads` option, which should be a keyword list.
  """

  @default_methods_list [:all, :one, :get, :insert, :update, :count, :destroy]

  defmacro __using__(opts \\ []) do
    schema = Keyword.get(opts, :schema)

    # If we are eager-loading, do so here.
    default_preloads = Keyword.get(opts, :default_preloads, [])

    only_list = Keyword.get(opts, :only, @default_methods_list)
    except = Keyword.get(opts, :except, [])

    # Build list of methods to be included
    methods = only_list -- except

    quote do
      alias Prairie.Repo

      import Ecto.Query

      @default_preloads unquote(default_preloads)
      @schema unquote(schema)

      @doc """
      Fetch the schema - useful at runtime
      """
      def schema() do
        @schema
      end

      @doc """
      Fetch the list of preloads - useful at runtime. Also useful if you want to
      take the list of preloads and then modify them in some way
      """
      def preloads() do
        @default_preloads
      end

      @doc """
      Given a queryable, use default preloads
      """
      def as_aggregate(queryable \\ @schema) do
        Repo.preload(queryable, @default_preloads)
      end

      if :all in unquote(methods) do
        @doc """
        Return a list of 0 or more items matching the Queryable.
        Defaults to all items of base schema
        """
        def all(queryable \\ @schema) do
          Repo.all(from(element in queryable))
        end
      end

      if :insert in unquote(methods) do
        @doc """
        Given a Changeset, insert it. Returns either:
        {:ok, record} or {:error, %Ecto.Changset{}}
        """
        def insert(%Ecto.Changeset{} = changeset) do
          Repo.insert(changeset)
        end
      end

      if :update in unquote(methods) do
        @doc """
        Given an Ecto.Changeset, either update or return error.
        Returns either {:ok, record} or {:error, %Ecto.Changeset{}}
        """
        def update(%Ecto.Changeset{} = changeset) do
          Repo.update(changeset)
        end
      end

      if :get in unquote(methods) or :one in unquote(methods) do
        @doc """
        Fetch a single record by queryable. Returns the first matching record or
        nil (if no matching items)

        Combine with a sort-by to get first/last records
        """
        def one(queryable \\ @schema) do
          Repo.one(from q in queryable, limit: 1, preload: unquote(default_preloads))
        end
      end

      if :get in unquote(methods) do
        @doc """
        Fetch a single record by ID.
        Return {:ok, record} or {:error, :not_found} -- the expectation is that
        if we have the ID we should expect to find the record.
        Accepts a queryable in case we want to do scoped lookups.
        """
        def get(queryable \\ @schema, id) do
          record = one(from(i in queryable, where: i.id == ^id))

          if record do
            {:ok, record}
          else
            {:error, @schema, :not_found}
          end
        end
      end

      if :count in unquote(methods) do
        @doc """
        Given a query, find out how many records match. By default, this counts
        all records
        """
        def count(queryable \\ @schema) do
          one(from q in queryable, select: count())
        end
      end

      if :destroy in unquote(methods) do
        @doc """
        Destroy a record once fetched
        """
        def destroy(record) do
          Repo.delete(record)
        end
      end
    end
  end
end
