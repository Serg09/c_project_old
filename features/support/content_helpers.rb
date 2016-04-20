module ContentHelpers
  def find_or_create_author_by_full_name(full_name)
    author_match = /^(\S+)\s(.*)$/.match(full_name)
    first_name = author_match[1]
    last_name = author_match[2]
    author = Author.find_by(first_name: first_name,
                            last_name: last_name)
    author ||= FactoryGirl.create(:approved_author, first_name: first_name,
                                                    last_name: last_name)
    author
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
