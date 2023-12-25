CREATE TRIGGER IF NOT EXISTS add_monolog_specific_filters
    AFTER INSERT ON lnav_events WHEN
    -- Check the event type
    jget(NEW.content, '/$schema') =
      'https://lnav.org/event-file-format-detected-v1.schema.json' AND
    -- Only create the filter when a given format is seen
    jget(NEW.content, '/format') IN ('monologproprietary', 'monologproprietary_newrelic') AND
    -- Don't create the filter if it's already there
    NOT EXISTS (SELECT 1 FROM lnav_view_filters WHERE pattern = 'health_check')
BEGIN
INSERT INTO lnav_view_filters (view_name, enabled, type, pattern) VALUES
  ('log', 1, 'OUT', 'health_check'),
  ('log', 1, 'OUT', '48fa5c8a-425a-41e9-9758-a212ae0fc1c8'), /* NR synthetic checks */
  ('log', 1, 'OUT', '5639faad-1c72-42d8-abd2-8e529792e6de'), /* NR synthetic checks */
  ('log', 1, 'OUT', 'OPTIONS /')
;
END;