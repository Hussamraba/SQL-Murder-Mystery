-- =============================================================
--  indexes.sql — SQL Murder Mystery Performance Investigation
--  Add your CREATE INDEX statements here (Task 2)
--
--  SQLite:  sqlite3 sql-murder-mystery.db < indexes.sql
--  Postgres: docker exec -i murder_db psql -U postgres -d murder_mystery < indexes.sql
-- =============================================================

-- ✅ Starter indexes — uncomment what you think will help, add your own

-- Q1: Filter crimes by city and type
-- CREATE INDEX idx_crime_city_type ON crime_scene_report(city, type);

-- Q2, Q6, Q8: JOIN person → drivers_license
-- CREATE INDEX idx_person_license_id ON person(license_id);

-- Q3: Filter gym check-ins by date
-- CREATE INDEX idx_checkin_date ON get_fit_now_check_in(check_in_date);

-- Q3: JOIN gym check-ins → members
-- CREATE INDEX idx_checkin_membership ON get_fit_now_check_in(membership_id);

-- Q4: Filter gym members by status
-- CREATE INDEX idx_member_status ON get_fit_now_member(membership_status);

-- Q4: JOIN gym members → person
-- CREATE INDEX idx_member_person_id ON get_fit_now_member(person_id);

-- Q5: Filter Facebook events by date range
-- CREATE INDEX idx_facebook_date ON facebook_event_checkin(date);

-- Q5, Q7: JOIN facebook/interview → person
-- CREATE INDEX idx_facebook_person_id ON facebook_event_checkin(person_id);
-- CREATE INDEX idx_interview_person_id ON interview(person_id);

-- Q4, Q8: JOIN person → income via SSN
-- CREATE INDEX idx_person_ssn ON person(ssn);

-- Q6: Filter drivers_license by hair color + car make (composite)
-- CREATE INDEX idx_license_hair_car ON drivers_license(hair_color, car_make);

-- ➕ Add your own indexes below based on your EXPLAIN QUERY PLAN analysis:


