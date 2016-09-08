module EmailFinder
  module EmailVariants
    def variants(first_name, last_name)
      first_initial = first_name[0]
      last_initial  = last_name[0]

      {
          'Firstname'               => first_name,
          'Lastname'                => last_name,
          'FirstinitialLastinitial' => "#{first_initial}#{last_initial}", # ns
          'Firstname_Lastname'      => "#{first_name}_#{last_name}", # neal_shyam
          'Firstinitial_Lastname'   => "#{first_initial}_#{last_name}", # n_shyam_
          'FirstnameLastname'       => "#{first_name}#{last_name}", # nealshyam
          'Firstname.Lastname'      => "#{first_name}.#{last_name}", # neal.shyam
          'FirstnameLastinitial'    => "#{first_name}#{last_initial}", # neals
          'FirstinitialLastname'    => "#{first_initial}#{last_name}", # nshyam
          'Firstname.Lastinitial'   => "#{first_name}.#{last_initial}", # neal.s
          'Firstinitial.LastName'   => "#{first_initial}.#{last_name}", # n.shyam
          'Lastname.Firstname'      => "#{last_name}.#{first_name}", # shyam.neal
          'LastnameFirstinitial'    => "#{last_name}#{first_initial}" # shyamn
      }
    end

    def email_variants(first_name, last_name)
      variants(first_name, last_name).values
    end
  end
end
