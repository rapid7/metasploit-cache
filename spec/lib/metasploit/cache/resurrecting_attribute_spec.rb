RSpec.describe Metasploit::Cache::ResurrectingAttribute do
  subject(:base_class) {
    described_class = self.described_class

    Class.new do
      extend described_class
    end
  }

  context '#resurrecting_attr_accessor' do
    subject(:resurrecting_attr_accessor) do
      base_class.resurrecting_attr_accessor attribute_name, &block
    end

    let(:attribute_name) do
      :phoenix
    end

    let(:block) do
      ->() { deferred }
    end

    context 'after declaring' do
      before(:each) do
        resurrecting_attr_accessor
      end

      context 'instance' do
        subject(:base_instance) do
          base_class.new
        end

        let(:instance_variable_name) do
          "@#{attribute_name}".to_sym
        end

        let(:read) do
          base_instance.send(attribute_name)
        end

        let(:writer_name) do
          "#{attribute_name}="
        end

        context 'read' do
          let(:deferred) {
            'Deferred'
          }

          before(:each) do
            memoized_deferred = self.deferred

            base_instance.define_singleton_method(:deferred) {
              memoized_deferred
            }
          end

          it 'should respond to <attribute_name>' do
            expect(base_instance).to respond_to attribute_name
          end

          context 'without value' do
            it 'should instance_exec block passed to resurrecting_attr_accessor' do
              expect(base_instance).to receive(:instance_exec).and_wrap_original { |original_instance_exec, &actual_block|
                expect(actual_block).to eq(block)

                original_instance_exec.call(&actual_block)
              }

              read
            end

            it 'should set value equal to return from block passed to resurrecting_attr_accessor' do
              expect(base_instance).to receive(writer_name).with(deferred)

              read
            end

            it 'should return value from block' do
              expect(read).to eq(deferred)
            end
          end

          context 'with value' do
            let(:value) do
              'written value'
            end

            before(:each) do
              base_instance.send(writer_name, value)
            end

            it 'should get strong reference using WeakRef#__getobj__' do
              weak_reference = base_instance.instance_variable_get instance_variable_name
              expect(weak_reference).to receive(:__getobj__)

              read
            end

            context 'with WeakRef::RefError' do
              it 'should get value from block again' do
                base_instance.send(writer_name, Object.new)

                instance_variable = base_instance.instance_variable_get instance_variable_name
                # using garbage collection was unreliable, probably because of the mark and sweep algorithm, so need
                # to simulate error directly.
                expect(instance_variable).to receive(:__getobj__).and_raise(WeakRef::RefError)

                expect(base_instance).to receive(:instance_exec).and_wrap_original { |original_instance_exec, &actual_block|
                  expect(actual_block).to eq(block)

                  original_instance_exec.call(&actual_block)
                }

                read
              end
            end

            context 'without WeakRef::RefError' do
              it 'should no call block again' do
                strong_reference = Object.new
                base_instance.send(writer_name, strong_reference)

                # using double GC as one wasn't enough and weakref's test double garbase collect, so assume it's enough.
                GC.start
                GC.start

                expect(base_instance).not_to receive(:instance_exec)

                read
              end
            end
          end
        end

        context 'write' do
          subject(:write) do
            base_instance.send(writer_name, value)
          end

          let(:value) do
            Object.new
          end

          it 'should respond to <attribute_name>=' do
            expect(base_instance).to respond_to writer_name
          end

          it 'should create a WeakRef to value' do
            write

            weak_reference = base_instance.instance_variable_get(instance_variable_name)
            expect(weak_reference).to be_a WeakRef
            expect(weak_reference.__getobj__).to eq(value)
          end

          context 'with nil' do
            let(:value) do
              nil
            end

            specify {
              expect {
                write
              }.to_not raise_error
            }
          end

          context 'without nil' do
            let(:value) do
              Object.new
            end

            it 'should be readable' do
              write
              expect(read).to eq(value)
            end

            it 'should return strong reference and not WeakRef' do
              expect(write).not_to be_a WeakRef
              expect(write).to equal(value)
            end
          end
        end
      end
    end
  end
end