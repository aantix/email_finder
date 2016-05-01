module EmailFinder
  module EmailVariants

    def email_variants(first_name, last_name)
      first_initial = first_name[0]
      last_initial  = last_name[0]

      [
          first_name,
          last_name,
          "#{first_initial}#{last_initial}", # ns
          "#{first_name}_#{last_name}", # neal_shyam
          "#{first_initial}_#{last_name}", # n_shyam_
          "#{first_name}#{last_name}", # nealshyam
          "#{first_name}.#{last_name}", # neal.shyam
          "#{first_name}#{last_initial}", # neals
          "#{first_initial}#{last_name}", # nshyam
          "#{first_name}.#{last_initial}", # neal.s
          "#{first_initial}.#{last_name}", # n.shyam
          "#{last_name}.#{first_name}", # shyam.neal
          "#{last_name}#{first_initial}" # shyamn
      ]
    end
  end
end
