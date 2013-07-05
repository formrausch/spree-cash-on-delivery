module Spree
  class CashOnDelivery::PaymentMethod < Spree::PaymentMethod
    preference :charge, :string, :default => '5.0'
    attr_accessible :preferred_charge

    def payment_profiles_supported?
      false # we want to show the confirm step.
    end

    def post_create(payment)
      payment.order.adjustments.each { |a| a.destroy if a.originator == self }
      payment.order.adjustments.create({ :amount => payment.payment_method.preferred_charge.to_f,
                                 :source => payment,
                                 :originator => self,
                                 :mandatory => true,
                                 :label => I18n.t(:cash_on_delivery_label) }, :without_protection => true)
    end

    def update_adjustment(adjustment, src)
      adjustment.update_attribute_without_callbacks(:amount, adjustment.order.payment.payment_method.preferred_charge.to_f)
    end


    def authorize(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def capture(payment, source, gateway_options)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def void(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def actions
      %w{capture void}
    end

    def can_capture?(payment)
      payment.state == 'pending' || payment.state == 'checkout'
    end

    def can_void?(payment)
      payment.state != 'void'
    end

    def source_required?
      false
    end

    #def provider_class
    #  self.class
    #end

    def payment_source_class
      nil
    end

    def method_type
      'cash_on_delivery'
    end
    
    def auto_capture?
      true
    end
    
  end
end
