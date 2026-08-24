# Learning Dashboard

> Progress tracker for [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests/).

## Progress at a glance

```dataview
TABLE length(rows) AS Chapters
FROM #chapter
GROUP BY status
```

## Chapters

```dataview
TABLE status AS Status, date AS Started, file.link AS Note
FROM #chapter
SORT file.name ASC
```

## Currently learning

```dataview
TABLE date AS Started
FROM #chapter
WHERE status = "in-progress"
SORT date ASC
```

## Open tasks

```tasks
not done
```

## Links

- [[learning-board|📋 Learning board (kanban)]]
- [[glossary|📖 Go vocabulary]]
