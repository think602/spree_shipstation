require 'spec_helper'

describe Spree::Shipment do
  context "between" do
    before do
      
      # TODO please save me from manually setting `updated_at`
      
      @active = []
      
      s1 = create_shipment(updated_at: Time.zone.now-1.day, order: create(:order))
      s1.order.update_attribute(:updated_at, Time.zone.now-1.day)
      s2 = create_shipment(updated_at: Time.zone.now+1.day, order: create(:order))
      s2.order.update_attribute(:updated_at, Time.zone.now+1.day)
      
      # Old shipment thats order was recently updated..
      s3 = create_shipment(updated_at: Time.zone.now-7.days, order: create(:order))
      s3.order.update_attribute(:updated_at, Time.zone.now)
      
      s4 = create_shipment(updated_at: Time.zone.now)
      s4.order.update_attribute(:updated_at, Time.zone.now)
      s5 = create_shipment(updated_at: Time.zone.now)
      s5.order.update_attribute(:updated_at, Time.zone.now)
      
      @active << s3
      @active << s4
      @active << s5
    end

    subject { Spree::Shipment.between(Time.zone.now-1.hour, Time.zone.now + 1.hours); }

    specify { should have(3).shipment }
    specify { should == @active }
  end

  context "exportable" do
    let!(:pending) { create_shipment(state: 'pending') }
    let!(:ready)   { create_shipment(state: 'ready')   }
    let!(:shipped) { create_shipment(state: 'shipped') }

    subject { Spree::Shipment.exportable }

    specify { should have(2).shipments }
    specify { should include(ready)}
    specify { should include(shipped)}
    specify { should_not include(pending)}
  end

  context "shipped_email" do
    let(:shipment) { create_shipment(state: 'ready') }

    context "enabled" do
      it "sends email" do
        Spree::Config.send_shipped_email = true
        mail_message = double("Mail::Message")
        Spree::ShipmentMailer.should_receive(:shipped_email).with(shipment).and_return mail_message
        mail_message.should_receive :deliver
        shipment.ship!
      end
    end

    context "disabled" do
      it "doesnt send email" do
        Spree::Config.send_shipped_email = false
        Spree::ShipmentMailer.should_not_receive(:shipped_email)
        shipment.ship!
      end
    end
  end

  def create_shipment(options={})
    FactoryGirl.create(:shipment, options).tap do |shipment|
      shipment.update_column(:state, options[:state]) if options[:state]
    end
  end
end
