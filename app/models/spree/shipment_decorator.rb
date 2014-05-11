Spree::Shipment.class_eval do
  scope :exportable, ->() { joins(:order).where('spree_shipments.state != (?)', 'pending') }

  def self.between(from_time, to_time)
    joins(:order).where('(spree_shipments.updated_at > (?) AND spree_shipments.updated_at < (?)) OR (spree_orders.updated_at > (?) AND spree_orders.updated_at < (?))',from_time, to_time, from_time, to_time)
  end

  private
    def send_shipped_email
      Spree::ShipmentMailer.shipped_email(self).deliver if Spree::Config.send_shipped_email
    end
end
