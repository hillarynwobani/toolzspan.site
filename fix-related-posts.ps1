$root = "c:\GravityProject\toolzspan.site\blog"

# Related posts mapping for each old post (3 related posts per post)
$relatedMap = @{
  'post-01.html' = @(@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'},@{h='PDF File Too Large? Here Is How to Fix It';f='post-19.html'},@{h='The Difference Between PDF Compression and PDF Optimization';f='post-20.html'})
  'post-02.html' = @(@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'},@{h='How to Merge Multiple PDFs Into One File';f='post-03.html'},@{h='How to Sign a PDF Without Printing It';f='post-10.html'})
  'post-03.html' = @(@{h='How to Split a PDF Into Separate Pages';f='post-04.html'},@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'},@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'})
  'post-04.html' = @(@{h='How to Merge Multiple PDFs Into One File';f='post-03.html'},@{h='How to Remove Pages From a PDF Without Software';f='post-18.html'},@{h='How to Rotate Pages in a PDF File';f='post-17.html'})
  'post-05.html' = @(@{h='How to Convert Images Into a PDF File';f='post-06.html'},@{h='How to Compress Images Without Losing Quality';f='post-21.html'},@{h='How to Resize an Image to Any Dimension for Free';f='post-22.html'})
  'post-06.html' = @(@{h='How to Convert PDF to JPG or PNG for Free';f='post-05.html'},@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'},@{h='How to Compress Images Without Losing Quality';f='post-21.html'})
  'post-07.html' = @(@{h='How to Remove a Password From a PDF File';f='post-08.html'},@{h='How to Add a Watermark to a PDF';f='post-09.html'},@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'})
  'post-08.html' = @(@{h='How to Add a Password to a PDF to Keep It Secure';f='post-07.html'},@{h='How to Sign a PDF Without Printing It';f='post-10.html'},@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'})
  'post-09.html' = @(@{h='How to Add a Password to a PDF to Keep It Secure';f='post-07.html'},@{h='How to Sign a PDF Without Printing It';f='post-10.html'},@{h='How to Remove a Password From a PDF File';f='post-08.html'})
  'post-10.html' = @(@{h='How to Add a Password to a PDF to Keep It Secure';f='post-07.html'},@{h='How to Add a Watermark to a PDF';f='post-09.html'},@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'})
  'post-11.html' = @(@{h='How to Convert a Scanned Image Into Editable Text';f='post-12.html'},@{h='How to Convert PDF Back to Word Without Losing Formatting';f='post-14.html'},@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'})
  'post-12.html' = @(@{h='What Is OCR and How Does It Work on PDFs?';f='post-11.html'},@{h='How to Convert PDF to JPG or PNG for Free';f='post-05.html'},@{h='How to Convert Images Into a PDF File';f='post-06.html'})
  'post-13.html' = @(@{h='How to Convert PDF Back to Word Without Losing Formatting';f='post-14.html'},@{h='How to Convert PowerPoint Presentations to PDF';f='post-15.html'},@{h='How to Convert Excel Spreadsheets to PDF';f='post-16.html'})
  'post-14.html' = @(@{h='How to Convert Word Documents to PDF for Free';f='post-13.html'},@{h='What Is OCR and How Does It Work on PDFs?';f='post-11.html'},@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'})
  'post-15.html' = @(@{h='How to Convert Word Documents to PDF for Free';f='post-13.html'},@{h='How to Convert Excel Spreadsheets to PDF';f='post-16.html'},@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'})
  'post-16.html' = @(@{h='How to Convert PowerPoint Presentations to PDF';f='post-15.html'},@{h='How to Convert Word Documents to PDF for Free';f='post-13.html'},@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'})
  'post-17.html' = @(@{h='How to Split a PDF Into Separate Pages';f='post-04.html'},@{h='How to Remove Pages From a PDF Without Software';f='post-18.html'},@{h='How to Merge Multiple PDFs Into One File';f='post-03.html'})
  'post-18.html' = @(@{h='How to Rotate Pages in a PDF File';f='post-17.html'},@{h='How to Split a PDF Into Separate Pages';f='post-04.html'},@{h='How to Merge Multiple PDFs Into One File';f='post-03.html'})
  'post-19.html' = @(@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'},@{h='The Difference Between PDF Compression and PDF Optimization';f='post-20.html'},@{h='The Best Free PDF Tools You Can Use Right Now';f='post-02.html'})
  'post-20.html' = @(@{h='PDF File Too Large? Here Is How to Fix It';f='post-19.html'},@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'},@{h='How to Compress Images Without Losing Quality';f='post-21.html'})
  'post-21.html' = @(@{h='How to Resize an Image to Any Dimension for Free';f='post-22.html'},@{h='How to Convert PDF to JPG or PNG for Free';f='post-05.html'},@{h='How to Compress a PDF Without Losing Quality';f='post-01.html'})
  'post-22.html' = @(@{h='How to Compress Images Without Losing Quality';f='post-21.html'},@{h='How to Convert PDF to JPG or PNG for Free';f='post-05.html'},@{h='How to Convert Images Into a PDF File';f='post-06.html'})
}

$fixed = 0
foreach ($postName in $relatedMap.Keys) {
  $fp = "$root\$postName"
  if (-not (Test-Path $fp)) { Write-Output "SKIP: $postName not found"; continue }
  $c = [System.IO.File]::ReadAllText($fp)
  if ($c -match 'related-posts') { Write-Output "SKIP: $postName already has related posts"; continue }
  
  $related = $relatedMap[$postName]
  $html = "`r`n      <div class=`"related-posts`">`r`n        <h3>Related Posts</h3>`r`n        <div class=`"related-posts-grid`">"
  foreach ($r in $related) {
    $html += "`r`n          <a href=`"$($r.f)`" class=`"related-post-card`"><h4>$($r.h)</h4></a>"
  }
  $html += "`r`n        </div>`r`n      </div>"
  
  # Insert before </article> or before </main>
  if ($c -match '</article>') {
    $c = $c -replace '</article>', "$html`r`n    </article>"
  } elseif ($c -match '</main>') {
    $c = $c -replace '</main>', "$html`r`n  </main>"
  }
  
  [System.IO.File]::WriteAllText($fp, $c, [System.Text.Encoding]::UTF8)
  Write-Output "Added related posts to: $postName"
  $fixed++
}

Write-Output "Done. Added related posts to $fixed blog posts."
