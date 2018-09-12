class CatRentalRequest < ApplicationRecord
    
    STATUS= [:pending , :denied , :pending]

    validates :cat_id, :end_date, :start_date, :status, presence: true
    validates :status, inclusion: STATUS

    belongs_to :cat,
    foreign_key: :cat_id,
    class_name: Cat:

    after_initialize :overlapping_approved_requests

    def pending?
        self.status == 'PENDING'
    end
    
    def overlapping_approved_requests
        overlapping_requests.where('status = \'APPROVED\'')
    end
    
    def overlapping_pending_requests
        overlapping_requests.where('status = \'PENDING\'')
    end

    def approve!
        raise 'not pending'  if self.status != 'PENDING'
        self.status = 'APPROVED'
        self.save!
    
        overlapping_pending_requests.each do |req|
            req.update!(status: 'DENIED')
        end
    end
    
    def approved?
    self.status == 'APPROVED'
    end

    def denied?
        self.status == 'DENIED'
    end

    def deny!
        self.status = 'DENIED'
        self.save!
    end


    def overlapping_requests
        CatRentalRequest
        .where.not(id: self.id)
        .where(cat_id: cat_id)
        .where.not('start_date > :end_date OR end_date < :start_date',
                    start_date: start_date, end_date: end_date)
    end

    def does_not_overlap_approved_request
        return if self.denied?
        msg = 'Request conflicts with existing approved request'
        errors[:base] << msg unless overlapping_approved_requests.empty?
    end
    
    def start_must_come_before_end
        return if start_date < end_date
        errors[:start_date] << 'must come before end date'
        errors[:end_date] << 'must come after start date'
    end

end
