CREATE TABLE workspace (
id UUID,
title TEXT
);

CREATE TABLE file (
id UUID,
workspace_id UUID,
path TEXT,
content TEXT
);
