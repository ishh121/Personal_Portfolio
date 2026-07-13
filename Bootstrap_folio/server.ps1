$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:3000/")
try {
    $listener.Start()
    Write-Host "Server started at http://localhost:3000/"
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Translate URL path to local file path
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/") {
            $localPath = "/index.html"
        }
        
        $cleanPath = $localPath.TrimStart('/')
        $filePath = Join-Path $PSScriptRoot $cleanPath
        
        if (Test-Path $filePath -PathType Leaf) {
            # Determine content type
            $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = "application/octet-stream"
            switch ($extension) {
                ".html" { $contentType = "text/html; charset=utf-8" }
                ".htm"  { $contentType = "text/html; charset=utf-8" }
                ".css"  { $contentType = "text/css" }
                ".js"   { $contentType = "application/javascript" }
                ".jpg"  { $contentType = "image/jpeg" }
                ".jpeg" { $contentType = "image/jpeg" }
                ".png"  { $contentType = "image/png" }
                ".svg"  { $contentType = "image/svg+xml" }
                ".gif"  { $contentType = "image/gif" }
                ".ico"  { $contentType = "image/x-icon" }
            }
            
            # Read and respond with file bytes
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.ContentType = $contentType
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
} catch {
    Write-Error $_.Exception.Message
} finally {
    $listener.Stop()
}
