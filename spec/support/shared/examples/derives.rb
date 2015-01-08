shared_examples_for 'derives' do |attribute, options={}|
  options.assert_valid_keys(:validates)

  derived = "derived_#{attribute}"
  validates = options.fetch(:validates)

  context attribute do
    it { should be_a Metasploit::Cache::Derivation }

    let(:validate) do
      base_class.validate_by_derived_attribute[attribute]
    end

    it "should declare #{attribute} is derived" do
      expect(validate).not_to be_nil
    end

    if validates
      it "should validate #{attribute}" do
        expect(validate).to eq(true)
      end

      context 'validation' do
        before(:each) do
          subject.send("#{attribute}=", value)
        end

        context "with #{attribute} matching #{derived}" do
          let(:value) do
            subject.send(derived)
          end

          it { should be_valid }
        end

        context "without #{attribute} matching #{derived}" do
          let(:value) do
            "not #{subject.send(derived)}"
          end

          it { should_not be_valid }

          it "should record error on #{attribute}" do
            subject.valid?

            expect(subject.errors[attribute]).to include("must match its derivation")
          end
        end
      end
    else
      it "should not validate #{attribute}" do
        expect(validate).to eq(false)
      end
    end

    context "##{derived}" do
      it "should respond to #{derived}" do
        expect(subject).to respond_to(derived)
      end

      it 'should not be nil or the spec that expect a change will fail' do
        expect(subject.send(derived)).not_to be_nil
      end
    end

    context 'callbacks' do
      context 'before validation' do
        before(:each) do
          subject.send("#{attribute}=", value)
        end

        context "with #{attribute}" do
          let(:value) do
            attribute_type = self.attribute_type(attribute)

            case attribute_type
              when :string, :text
                'existing_value'
              when :datetime
                DateTime.new
              else
                raise ArgumentError,
                      "Don't know how to make valid existing value for attribute type (#{attribute_type.inspect})"
            end
          end

          it "should not change #{attribute}" do
            expect {
              subject.valid?
            }.to_not change {
              subject.send(attribute)
            }
          end
        end

        context "without #{attribute}" do
          let(:value) do
            nil
          end

          it "should set #{attribute} to #{derived}" do
            expect {
              subject.valid?
            }.to change {
              subject.send(attribute)
            }

            expect(subject.send(attribute)).to eq(subject.send(derived))
          end
        end
      end
    end
  end
end