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

## End Goal

---

# End Goal

```elixir
BisonQueries.base_query()
|> BisonQueries.in_state("NE")
|> BisonQueries.due_for_appointment()
|> BisonQueries.no_next_appointment_scheduled()
|> BisonRepo.all()
```

---

# TIME TO WRITE
![](bison_2.jpeg)

---

# Touchpoints

![](bison.jpg)

---

# Touchpoints

`Ecto.Query` gives us almost everything we need

---

# Touchpoints

Use to establish a single level of abstraction and "hide" SQL.

---

# Touchpoints

Named bindings carry `joins`, `has_named_binding?` helps reduce duplication.

---

# Touchpoints

Using a default query lets you get away with a lot.

---

# Touchpoints

Specific application of pipelines through tokens to get a reducer

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

