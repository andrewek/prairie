defmodule Prairie.Veterinary.BisonRepo do
  use GenericRepo,
    schema: Prairie.Bison.Bison,
    default_preloads: [records: [veterinary_staff_member: []], prairie: []]
end
