build-lists: true
slide-transition: true


![](bison.jpg)

---

[.background-color: #FFF]
[.text: #222, alignment(center)]
[.header: #555]

## Andrew Ek, Principal Engineer at Launch Scout

`@ektastrophe` on Twitter

`andrew.ek@launchscout.com`

`https://github.com/andrewek/prairie`

![inline](launch_scout_logo.svg)

---

![fit](family_2.jpg)

---

![](bison_3.jpeg)

---

![](family.jpeg)

---

![](bison.jpg)

---

![](bison.jpg)

## Better Data Access with Composable Ecto Queries

### Andrew Ek, CodeBEAM America 2022

---

![](bison_2.jpeg)

## Preview

---

# Preview

```elixir
BisonQueries.base_query()
|> BisonQueries.by_state_code("NE")
|> BisonQueries.by_due_for_appointment()
|> BisonQueries.as_aggregate()
|> BisonRepo.all()
```

---

![](bison_2.jpeg)

---

# Touchpoints

![](bison.jpg)

---

# Touchpoints

The main goal is to add readability and reduce cognitive load.

---

# Touchpoints

`Ecto.Query` gives us almost everything we need.

---

# Touchpoints

Named bindings carry `joins`; `has_named_binding?` helps reduce duplication.

---

# Touchpoints

Using a default query lets you get away with a lot.

---

![](bison.jpg)

# _Fin_

---

[.background-color: #FFF]
[.header: #555]
[.text: #222, alignment(center)]

## Andrew Ek, Principal Engineer at Launch Scout

`@ektastrophe` on Twitter

`andrew.ek@launchscout.com`

`https://github.com/andrewek/prairie`

![inline](launch_scout_logo.svg)

