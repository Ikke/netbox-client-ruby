require 'spec_helper'

describe NetboxClientRuby::IpAddress, faraday_stub: true do
  let(:class_under_test) { NetboxClientRuby::IpAddress }
  let(:base_url) { '/api/ipam/ip-addresses/' }
  let(:response) { File.read("spec/fixtures/ipam/ip-address_#{entity_id}.json") }

  let(:expected_address) { '10.0.0.1/8' }
  let(:entity_id) { 1 }
  let(:request_url) { "#{base_url}#{entity_id}.json" }

  subject { class_under_test.new entity_id }

  describe '#id' do
    it 'shall be the expected id' do
      expect(subject.id).to eq(entity_id)
    end
  end

  describe '#address' do
    it 'should fetch the data' do
      expect(faraday).to receive(:get).and_call_original

      subject.address
    end

    it 'shall be the expected address' do
      expect(subject.address).to eq(expected_address)
    end
  end

  {
    vrf: NetboxClientRuby::Vrf,
    tenant: NetboxClientRuby::Tenant,
    # interface: NetboxClientRuby::Interface,
    status: NetboxClientRuby::IpAddressStatus
  }.each_pair do |method_name, expected_type|
    describe ".#{method_name}" do
      it 'should fetch the data' do
        expect(faraday).to receive(:get).and_call_original

        expect(subject.public_send(method_name)).to_not be_nil
      end

      it 'shall return the expected type' do
        expect(subject.public_send(method_name)).to be_a(expected_type)
      end
    end
  end

  describe '.status' do
    it 'should assign the correct value' do
      expect(subject.status.label).to eq('Active')
    end
  end

  describe '.delete' do
    let(:request_method) { :delete }
    let(:response_status) { 204 }
    let(:response) { nil }

    it 'should delete the object' do
      expect(faraday).to receive(request_method).and_call_original
      subject.delete
    end
  end

  describe '.update' do
    let(:address) { '192.168.1.1/24' }
    let(:request_method) { :patch }
    let(:request_params) { { 'address' => address } }

    it 'should update the object' do
      expect(faraday).to receive(request_method).and_call_original
      expect(subject.update(address: address).address).to eq(expected_address)
    end
  end

  describe '.reload' do
    it 'should reload the object' do
      expect(faraday).to receive(request_method).twice.and_call_original

      subject.reload
      subject.reload
    end
  end

  describe '.save' do
    let(:address) { '192.168.1.1/24' }
    let(:request_params) { { 'address' => address } }

    context 'update' do
      let(:request_method) { :patch }

      subject do
        entity = class_under_test.new entity_id
        entity.address = address
        entity
      end

      it 'does not call PATCH until save is called' do
        expect(faraday).to_not receive(request_method)
        expect(faraday).to_not receive(:get)

        expect(subject.address).to eq(address)
      end

      it 'calls PATCH when save is called' do
        expect(faraday).to receive(request_method).and_call_original

        expect(subject.save).to be(subject)
      end

      it 'Reads the anwer from the PATCH answer' do
        expect(faraday).to receive(request_method).and_call_original

        subject.save
        expect(subject.address).to eq(expected_address)
      end
    end

    context '.new' do
      let(:request_method) { :post }
      let(:request_url) { base_url }

      subject do
        entity = class_under_test.new
        entity.address = address
        entity
      end

      it 'does not POST until save is called' do
        expect(faraday).to_not receive(request_method)
        expect(faraday).to_not receive(:get)

        expect(subject.address).to eq(address)
      end

      it 'POSTs the data upon a call of save' do
        expect(faraday).to receive(request_method).and_call_original

        expect(subject.save).to be(subject)
      end

      it 'Reads the answer from the POST' do
        expect(faraday).to receive(request_method).and_call_original

        subject.save

        expect(subject.id).to be(1)
        expect(subject.address).to eq(expected_address)
      end
    end
  end
end