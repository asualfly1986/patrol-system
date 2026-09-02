-- ========================================================
-- PATROL MV & LV Tracking System: Supabase Database Schema
-- Run this script in Supabase Dashboard -> SQL Editor
-- ========================================================

-- 1. Enable PostGIS Extension (Optional for GIS spatial queries)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Create Projects Table
CREATE TABLE IF NOT EXISTS projects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Surveys Table
CREATE TABLE IF NOT EXISTS surveys (
    id TEXT PRIMARY KEY,
    project_id TEXT REFERENCES projects(id) ON DELETE CASCADE,
    pole_id TEXT NOT NULL,
    landmark TEXT,
    voltage TEXT NOT NULL CHECK (voltage IN ('MV', 'LV')),
    category TEXT NOT NULL,
    vehicle_types TEXT[] DEFAULT '{}',
    notes TEXT,
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    gps_source TEXT DEFAULT 'manual',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    before_photo_url TEXT,
    after_photo_url TEXT,
    survey_date TIMESTAMPTZ DEFAULT NOW(),
    completed_date TIMESTAMPTZ,
    closure_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Enable Row Level Security (RLS) - Public Read/Write for Field Teams
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE surveys ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read-write for projects" 
ON projects FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read-write for surveys" 
ON surveys FOR ALL USING (true) WITH CHECK (true);

-- 5. Enable Realtime Replication for instant WebSocket updates
ALTER PUBLICATION supabase_realtime ADD TABLE projects;
ALTER PUBLICATION supabase_realtime ADD TABLE surveys;

-- 6. Insert Initial Sample Project
INSERT INTO projects (id, name, description)
VALUES ('proj-feeder-01', 'ฟีดเดอร์ 01 สายหลัก (สถานีไฟฟ้า 115kV)', 'งานสำรวจความพร้อมระบบจำหน่ายสายส่งและกิ่งไม้รุกล้ำ')
ON CONFLICT (id) DO NOTHING;
