module ContentHelpers
  def find_or_create_user_by_full_name(full_name)
    user_match = /^(\S+)\s(.*)$/.match(full_name)
    first_name = user_match[1]
    last_name = user_match[2]
    user = User.find_by(first_name: first_name,
                        last_name: last_name)
    user || FactoryGirl.create(:user, first_name: first_name,
                                               last_name: last_name)
  end

  ADDRESS_REGEX = /\A(?<line1>[^,]+),(?:(?<line2>[^,]+),)?(?<city>[^,]+),\s?(?<state>[a-z]{2})\s+(?<postal_code>\d{5}(?:-\d{4})?)\z/i
  def parse_address(address_string)
    ADDRESS_REGEX.match(address_string)
  end

  def parse_table(table_elem)
    rows = table_elem.all('tr')
    rows.map { |r| r.all('td,th').map { |c| c.text.strip } }
  end
end
World(ContentHelpers)
