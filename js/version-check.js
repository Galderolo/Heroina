// Lista de archivos JS y HTML a monitorear
const FILES_TO_CHECK = [
    'js/data.js',
    'js/game.js',
    'js/storage.js',
    'js/modals.js',
    'index.html',
    'misiones.html',
    'tienda.html',
    'custom.html'
];

function calculateFileHash(content) {
    let hash = 0;
    const length = content.length;
    
    for (let i = 0; i < content.length; i++) {
        const char = content.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // Convertir a entero de 32 bits
    }
    
    return `${length}-${Math.abs(hash).toString(36)}`;
}

function getStoredFileVersions() {
    try {
        const versions = localStorage.getItem('app_file_versions');
        return versions ? JSON.parse(versions) : {};
    } catch (error) {
        console.error('Error getting file versions:', error);
        return {};
    }
}

function saveStoredFileVersions(versions) {
    try {
        localStorage.setItem('app_file_versions', JSON.stringify(versions));
        return true;
    } catch (error) {
        console.error('Error saving file versions:', error);
        return false;
    }
}

async function checkFilesVersion() {
    const storedVersions = getStoredFileVersions();
    const newVersions = {};
    const changedFiles = [];
    
    try {
        const fetchPromises = FILES_TO_CHECK.map(async (filePath) => {
            try {
                const url = `${filePath}?v=${Date.now()}`;
                const response = await fetch(url, {
                    cache: 'no-store',
                    headers: {
                        'Cache-Control': 'no-cache'
                    }
                });
                
                if (!response.ok) {
                    console.warn(`No se pudo cargar ${filePath}`);
                    return null;
                }
                
                const content = await response.text();
                const hash = calculateFileHash(content);
                newVersions[filePath] = hash;
                
                if (storedVersions[filePath] && storedVersions[filePath] !== hash) {
                    changedFiles.push(filePath);
                }
                
                return { filePath, hash, changed: storedVersions[filePath] !== hash };
            } catch (error) {
                console.error(`Error al verificar ${filePath}:`, error);

                if (storedVersions[filePath]) {
                    newVersions[filePath] = storedVersions[filePath];
                }
                return null;
            }
        });
        
        await Promise.all(fetchPromises);
        
        for (const filePath of FILES_TO_CHECK) {
            if (newVersions[filePath] && !storedVersions[filePath]) {
                changedFiles.push(filePath);
            }
        }
        
        return {
            needsUpdate: changedFiles.length > 0,
            changedFiles,
            newVersions
        };
    } catch (error) {
        console.error('Error al verificar versiones:', error);
        
        return {
            needsUpdate: false,
            changedFiles: [],
            newVersions: storedVersions
        };
    }
}
