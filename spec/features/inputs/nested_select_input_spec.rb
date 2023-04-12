require "rails_helper"

describe "Nested Select Input", type: :feature do
  context "with nil city" do
    before do
      register_form(Invoice, false) do |f|
        f.input :city_id, as: :nested_select,
                          level_1: {
                            attribute: :country_id,
                            width: "30px"
                          },
                          level_2: {
                            attribute: :region_id,
                            url: "/fakeurl",
                            response_root: "my_regions"
                          },
                          level_3: {
                            attribute: :city_id
                          }
      end

      visit edit_admin_invoice_path(create_invoice)
    end

    it "shows empty select controls" do
      expect(page.text).not_to match(/Chile/)
      expect(page.text).not_to match(/Metropolitana/)
      expect(page.text).not_to match(/Santiago/)
    end

    it "uses the custom url" do
      expect(page.html).to match('fakeurl')
    end

    it "changes input width" do
      on_input_ctx("invoice_region_id") { expect_slimselect_data_option("width", "30px") }
    end

    it "changes response root" do
      on_input_ctx("invoice_region_id") do
        expect_slimselect_data_option("response-root", "my_regions")
      end
    end
  end

  context "with selected city" do
    before do
      register_page(Country, false) {}
      register_page(Region, false) {}
      register_page(City, false) {}

      register_form(Invoice, false) do |f|
        f.input :city_id, as: :nested_select,
                          level_1: { attribute: :country_id },
                          level_2: {
                            attribute: :region_id,
                            collection: Region.all
                          },
                          level_3: { attribute: :city_id }
      end

      create_cities
      create_invoice(city: @santiago)
      visit edit_admin_invoice_path(@invoice)
    end

    it "shows filled select controls based on defined city_id", js: true do
      on_input_ctx("invoice_country_id") { expect_slimselect_selection("Chile") }
      on_input_ctx("invoice_region_id") { expect_slimselect_selection("Metropolitana") }
      on_input_ctx("invoice_city_id") { expect_slimselect_selection("Santiago") }
    end

    context "updating the highest hierachy level" do
      before do
        on_input_ctx("invoice_country_id") do
          open_slimselect_options
          slimselect_search_input.set("Arg")
        end
      end

      it "shows results based on entered text", js: true do
        expect_slimselect_result_text_to_eq(1, "Argentina")
      end

      context "after click option" do
        before do
          on_input_ctx("invoice_country_id") { click_slimselect_option("Argentina") }
        end

        it "sets value", js: true do
          on_input_ctx("invoice_country_id") { expect_slimselect_selection("Argentina") }
        end

        it "resets children select controls after click option", js: true do
          on_input_ctx("invoice_region_id") { expect_slimselect_empty_selection }
          on_input_ctx("invoice_city_id") { expect_slimselect_empty_selection }
        end
      end
    end

    context "updating medium level" do
      before do
        on_input_ctx("invoice_region_id") do
          open_slimselect_options
          slimselect_search_input.set("Antof")
        end
      end

      it "shows results based on entered text", js: true do
        expect_slimselect_result_text_to_eq(1, "Antofagasta")
      end

      context "after click option" do
        before do
          on_input_ctx("invoice_region_id") { click_slimselect_option("Antofagasta") }
        end

        it "sets value", js: true do
          on_input_ctx("invoice_region_id") { expect_slimselect_selection("Antofagasta") }
        end

        it "preserves parent value", js: true do
          on_input_ctx("invoice_country_id") { expect_slimselect_selection("Chile") }
        end

        it "resets children values", js: true do
          on_input_ctx("invoice_city_id") { expect_slimselect_empty_selection }
        end
      end
    end

    context "updating lowest level" do
      before do
        on_input_ctx("invoice_city_id") do
          open_slimselect_options
          slimselect_search_input.set("na")
        end
      end

      it "shows results based on entered text", js: true do
        expect_slimselect_result_text_to_eq(1, "Colina")
      end

      context "after click option", js: true do
        before do
          on_input_ctx("invoice_city_id") { click_slimselect_option("Colina") }
        end

        it "sets value", js: true do
          on_input_ctx("invoice_city_id") { expect_slimselect_selection("Colina") }
        end

        it "preserves parent values", js: true do
          on_input_ctx("invoice_country_id") { expect_slimselect_selection("Chile") }
          on_input_ctx("invoice_region_id") { expect_slimselect_selection("Metropolitana") }
        end
      end
    end

    context "with general options" do
      before do
        register_page(Region, false) {}
        register_page(City, false) {}

        register_form(Invoice, false) do |f|
          f.input :city_id, as: :nested_select,
                            fields: [:name, :information],
                            display_name: :id,
                            minimum_input_length: 5,
                            level_1: { attribute: :region_id },
                            level_2: { attribute: :city_id }
        end

        create_cities
        create_invoice(city: @santiago)
        visit edit_admin_invoice_path(@invoice)
      end

      it "sets display name on each select", js: true do
        on_input_ctx("invoice_region_id") { expect_slimselect_selection(@metropolitana.id) }
        on_input_ctx("invoice_city_id") { expect_slimselect_selection(@santiago.id) }
      end

      it "sets general minimum_input_length option", js: true do
        msg = "Input is too short"
        slimselect_region_id = nil
        slimselect_city_id = nil

        on_input_ctx("invoice_region_id") do
          slimselect_region_id = slimselect_original_select_id
          open_slimselect_options
        end
        slimselect_search_input(slimselect_region_id).set("1234")
        expect_slimselect_error("Please enter 5 or more characters")
        sleep 1
        close_slimselect_options(slimselect_region_id)

        on_input_ctx("invoice_city_id") do
          slimselect_city_id = slimselect_original_select_id
          open_slimselect_options
        end
        slimselect_search_input(slimselect_city_id).set("1234")
        expect_slimselect_error("Please enter 5 or more characters")
      end

      it "uses general fields to search", js: true do
        on_input_ctx("invoice_city_id") do
          open_slimselect_options
          slimselect_search_input.set("info1")
        end
        expect_slimselect_result_text_to_eq(1, @santiago.id)
      end
    end
  end

  context "with filters"  do
    before do
      register_page(Country, false) {}
      register_page(Region, false) {}
      register_page(City, false) {}

      register_form(Invoice, false) do |f|
        f.input :city_id, as: :nested_select,
                          level_1: { attribute: :country_id },
                          level_2: {
                            attribute: :region_id,
                            filters: { name_contains: 'Met' }
                          },
                          level_3: { attribute: :city_id }
      end

      create_cities
      create_invoice(city: @colina)
      visit edit_admin_invoice_path(@invoice)
    end

    it "shows filled select controls based on defined city_id", js: true do
      on_input_ctx("invoice_country_id") { expect_slimselect_selection("Chile") }
      on_input_ctx("invoice_region_id") { expect_slimselect_selection("Metropolitana") }
      on_input_ctx("invoice_city_id") { expect_slimselect_selection("Colina") }
    end

    context "updating medium level" do
      let(:slimselect_id) do
        on_input_ctx("invoice_region_id") { slimselect_original_select_id }
      end

      before do
        on_input_ctx("invoice_region_id") do
          open_slimselect_options
          slimselect_search_input.set("a")
        end
      end

      it "shows no results based on entered text", js: true do
        expect_slimselect_options_count_to_eq(1, slimselect_id)
      end
    end
  end

  context "without filters"  do
    before do
      register_page(Country, false) {}
      register_page(Region, false) {}
      register_page(City, false) {}

      register_form(Invoice, false) do |f|
        f.input :city_id, as: :nested_select,
                          level_1: { attribute: :country_id },
                          level_2: { attribute: :region_id },
                          level_3: { attribute: :city_id }
      end

      create_cities
      create_invoice(city: @colina)
      visit edit_admin_invoice_path(@invoice)
    end

    it "shows filled select controls based on defined city_id", js: true do
      on_input_ctx("invoice_country_id") { expect_slimselect_selection("Chile") }
      on_input_ctx("invoice_region_id") { expect_slimselect_selection("Metropolitana") }
      on_input_ctx("invoice_city_id") { expect_slimselect_selection("Colina") }
    end

    context "updating medium level" do
      let(:slimselect_id) do
        on_input_ctx("invoice_region_id") { slimselect_original_select_id }
      end

      before do
        on_input_ctx("invoice_region_id") do
          open_slimselect_options
          slimselect_search_input.set("a")
        end
      end

      it "shows no results based on entered text", js: true do
        expect_slimselect_options_count_to_eq(2, slimselect_id)
      end
    end
  end

  context "with nested resources" do
    before do
      register_page(Region, false) {}
      register_page(Country, false) {}
      register_page(City, false) {}

      register_form(Department, false) do |f|
        f.has_many :departments_cities, allow_destroy: true do |city|
          city.input :city_id, as: :nested_select, required: true,
                               display_name: :name,
                               minimum_input_length: 0,
                               level_1: { attribute: :country_id },
                               level_2: { attribute: :region_id },
                               level_3: { attribute: :city_id }
        end
      end
      create_cities
      visit new_admin_department_path
    end

    it "sets new values correctly", js: true do
      click_add_nested
      prefix = "department_departments_cities_attributes_"
      santiago = @santiago.name
      on_nested_ctx(1) do
        slimselect_country_id = nil
        slimselect_region_id = nil
        slimselect_city_id = nil

        on_input_ctx("#{prefix}0_country_id") do
          slimselect_country_id = slimselect_original_select_id
          open_slimselect_options
        end
        slimselect_search_input(slimselect_country_id).set("Ch")
        click_slimselect_option(@chile.name, slimselect_country_id)

        on_input_ctx("#{prefix}0_region_id") do
          slimselect_region_id = slimselect_original_select_id
          open_slimselect_options
        end
        slimselect_search_input(slimselect_region_id).set("Met")
        click_slimselect_option(@metropolitana.name, slimselect_region_id)

        on_input_ctx("#{prefix}0_city_id") do
          slimselect_city_id = slimselect_original_select_id
          open_slimselect_options
        end
        slimselect_search_input(slimselect_city_id).set("San")
        click_slimselect_option(santiago, slimselect_city_id)
        expect_nested_slimselect_result_text_to_eq(3, santiago)
      end

      click_add_nested
      on_nested_ctx(2) do
        slimselect_country_id = nil
        slimselect_region_id = nil
        slimselect_city_id = nil
        mendoza = @mendoza.name

        on_input_ctx("#{prefix}1_country_id") do
          slimselect_country_id = slimselect_original_select_id
          open_slimselect_options
        end
        click_slimselect_option(@argentina.name, slimselect_country_id)

        on_input_ctx("#{prefix}1_region_id") do
          slimselect_region_id = slimselect_original_select_id
          open_slimselect_options
        end
        click_slimselect_option(@cuyo.name, slimselect_region_id)

        on_input_ctx("#{prefix}1_city_id") do
          slimselect_city_id = slimselect_original_select_id
          open_slimselect_options
        end
        click_slimselect_option(mendoza, slimselect_city_id)
        expect_nested_slimselect_result_text_to_eq(3, mendoza)
      end

      on_nested_ctx(1) do
        expect_nested_slimselect_result_text_to_eq(3, santiago)
      end
    end
  end
end
