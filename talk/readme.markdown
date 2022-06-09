build-lists: true
slide-transition: true


![](bison.jpg)

---

![](bison.jpg)

# Get Your CRUD Together

### Andrew Ek, ElixirConf EU 2022

---

## About Me

^ Keep it brief
^ Principal engineer @ Launch Scout

---

[.background-color: #FFF]
[.text: #000, alignment(left)]

Principal Engineer at Launch Scout

`@ektastrophe` on Twitter

`andrew.ek@launchscout.com`

https://github.com/andrewek/prairie

![.right](launch_scout_logo.svg)

---

## Some Horror Stories

---

## One Version of Layers

1. Work-starter
2. Container
3. Bounded Context
4. Data Access
5. Functional Core

---

![](bison.jpg)

## The Data Access Layer

---

## The Data Access Layer

Our data might live in:

+ A database
+ A GenServer
+ An ETS Table
+ Some remote service or third party application

---

## The Data Access Layer

We might see these problems:

+ Variations in data representation
+ Failed book-keeping after business events
+ Small changes have big effects
+ Overreliance on callbacks

---

## Patterns I Like

+ Strict separation between business logic and book-keeping
+ Finding aggregates in context
+ Composable Queries
+ Sensible defaults (e.g. `GenericRepo`)

---

## Business Logic or Book-Keeping?

---

## Finding Aggregates in Context

^ A context is a business domain, with its own ubiquitous language
^ Aggregate as a graph of data in context
^ Usually when we access data, it's in context
^ A consistent aggregate lets us make predictable choices elsewhere

---

![](bison.jpg)

## Composable Queries

---

## Composable Queries

+ Pipeline-able operations
+ Takes a query and returns a query

---

## Composable Queries

```elixir
defmodule Prairie.Bison.Queries do
  # ....

  def with_status(query \\ Bison, status) do
    from bison in query,
      where: bison.status == ^status
  end
end
```

---

## Composable Queries

```elixir
defp with_prairie(query) do
  if has_named_binding?(query, :prairie) do
    query
  else
    from q in query
    |> join: prairie in assoc(q, :prairie), as: :prairie
  end
end
```

^ makes use of `has_named_binding?` on joined bindings

---

## Composable Queries

```elixir
def in_active_prairie(query \\ Bison, id) do
  query
  |> with_prairie()
  |> where(
       [_, prairie: prairie],
       prairie.active == true and prairie.id == ^id
     )
end
```

---

## Composable Queries

```elixir
def all_in_active_prairie(status, prairie_id) do
  Bison
  |> with_status(status)
  |> in_active_prairie(prairie_id)
  |> BisonRepo.all()
end
```

---

## Composable Queries

+ Describes meaning, rather than implementation
+ Reads like Elixir, rather than like SQL
+ Standardizes access
+ Reduces cognitive overhead

---

![](bison.jpg)
## The `GenericRepo`

---

## The `GenericRepo`

+ List all (or paginate)
+ Get one
+ Create
+ Update
+ Delete
+ Count

^ Easy to generate
^ Consistent interface
^ Consistent shape of data
^ Customizable by context, aggregate

---

## The `GenericRepo`

```elixir
defmodule Prairie.Bison.Repo do
  use GenericRepo,
    schema: Prairie.Bison.Bison,
    default_preloads: [check_up_charts: []],
    base_repo: Prairie.Repo
end
```

---

```elixir
defmodule GenericRepo do
  defmacro __using__(opts \\ []) do
    schema = Keyword.pop!(opts, :schema)
    default_preloads = Keyword.get(opts, :default_preloads, [])
    base_repo = Keyword.pop!(opts, :base_repo)

    # ...

  end
end
```

---

```elixir
  # inside the defmacro block

  quote do
    alias unquote(schema)
    alias unquote(base_repo), as: BaseRepo

    import Ecto.Query

    @schema unquote(schema)
    @default_preloads unquote(default_preloads)

    # ...
  end
```

---

```elixir
  # Inside the quote block

  def one(queryable \\ @schema) do
    BaseRepo.all(
      from element in queryable,
      preload: @default_preloads
    )
  end
```

---

```elixir
  # Inside the quote block

  def get(queryable \\ @schema, id) do
    record = one(
      from element in queryable,
      where: element.id == ^id, limit: 1
    )

    if record do
      {:ok, record}
    else
      {:error, :not_found, @schema}
    end
  end
```
---

![](bison.jpg)
## Some Variants

---

## Some Variants

Instead of `%Something{}` or `nil`, consider `{:ok, %Something{}}` and `{:error, :not_found}`

Or `{:error, Something, :not_found}`

---

## Some Variants

You might want callbacks (e.g. Pub/Sub) upon certain successful operations

---

## Some Variants

```elixir
def update(%Ecto.Changeset{} = changeset) do
  changeset
  |> Repo.update()
  |> maybe_publish(:updated)
end

defp maybe_publish({:ok, record}, action) do
  publish(record, action)

  {:ok, record}
end

defp maybe_publish(result, _action) do
  result
end
```

---

## Some Variants

```elixir
def update(%Ecto.Changeset{} = changeset, callback_fn \\ nil) do
  changeset
  |> Repo.update()
  |> maybe_success_callback(callback_fn)
end

defp maybe_success_callback({:ok, record}, callback_fn) when is_function(callback_fn) do
  callback_fn.(record)

  {:ok, record}
end

defp maybe_success_callback(result, _callback_fn) do
  result
end
```

---

## Some Variants

Depending on your interface, consider using many small changesets rather than one big one

---

## Some Variants

Don't be afraid to access the same data in different ways depending on context. A given table may appear in several contexts.

---

```elixir
defmodule Prairie.Bison.Repo do
  use GenericRepo,
    schema: Prairie.Bison.Bison,
    base_repo: Prairie.Repo,
    default_preloads: [
      prairie: [],
      keepers: [],
      offspring: []
    ]
end
```

---

```elixir
defmodule Prairie.VeterinaryCare.BisonRepo do
  use GenericRepo,
    schema: Prairie.Bison.Bison,
    base_repo: Prairie.Repo,
    default_preloads: [
      check_up_charts: [],
      veterinarian: [],
      vaccinations: []
    ]
end
```

---

## Some Variants

---

![](bison.jpg)
## Why Might We Do This?

---

## Why Might We Do This?

+ Reduce bugs caused by subtle variants
+ Reduce cognitive overhead
+ Improve speed to market
+ Better (more normalized) data model

---

![](bison.jpg)

## Why Might We _Not_ Do This?

---

![](bison.jpg)
## Schema-less Changesets and APIs

---

## Schema-less Changesets and APIs

If we're using external APIs, we can use schema-less changesets (and a pseudo-repo) to maintain a consistent interface.

---

## Schema-less Changesets and APIs

```elixir
defmodule Praire.VaxxaPro.Record do
  import Ecto.Changeset
  alias __MODULE__

  defstruct [:name, :date, :bison_id, :dose]

  @types %{id: :string, name: :string, dose: :integer, date: :string, bison_id: :string}

  def changeset(%Record{} = record, attrs \\ %{}) do
    {record, @types}
    |> cast(attrs, [:name, :date, :bison_id, :dose])
    |> validate_required([:name, :date, :bison_id, :dose])
  end
end
```

---

## Schema-less Changesets and APIs

```elixir
defmodule Praire.VaxxaPro.Repo do
  alias Praire.VaxxaPro.Record

  def insert(attrs \\ %{}) do
    %Record{}
    |> Record.changeset(attrs)
    |> post()
    |> parse()
  end
end
```

---

## Schema-less Changesets and APIs

1. User input
2. Changeset (ensure well-formed)
3. Post to remote API
4. Transform result into `{:ok, Something{}}` or `{:error, changeset}`

---

![](bison.jpg)

## General Notions

---

## General Notions

+ Separate book-keeping from business logic
+ Prefer consistent representations (within a context) where possible
+ Structs, aggregates, and the "Repo" pattern help build consistency
+ Don't be afraid to normalize your database
+ Be mindful of performance v. speed to delivery

---

![](bison.jpg)
## _Fin_

---

https://github.com/andrewek/prairie

`@ektastrophe` on Twitter

`andrew.ek@launchscout.com`

