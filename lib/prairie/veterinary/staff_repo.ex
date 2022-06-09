defmodule Prairie.Veterinary.StaffRepo do
  use GenericRepo,
    schema: Prairie.Veterinary.StaffMember,
    default_preloads: [records: []]
end
