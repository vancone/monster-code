function getModelName(model)
    local modelName = model.Name
    local ModelName = modelName:gsub('^%l',string.upper)
    return modelName, ModelName
end

function generatePom()
    local files = {}
    local otherDependencies = ''
    local finalSource = source

    local redisInjected = false
    for i = 1, #(project.Deployment.Env) do
        local env = project.Deployment.Env[i]
        -- Add Redis dependency
        if #(project.Deployment.Env[1].Middleware.Redis) > 0 and redisInjected == false then
            otherDependencies = otherDependencies .. '\n\n' ..
                go_add_indent(go_read_template_file(template.Name, 'content/pom/redis.xml'), 8)
            redisInjected = true
        end
    end

    if plugins['vancone-passport-sdk'] == true then
        otherDependencies = otherDependencies .. '\n\n' ..
            go_add_indent(go_read_template_file(template.Name, 'content/pom/vancone-passport-sdk.xml'), 8)
    end

    finalSource = string.gsub(finalSource, '${otherDependencies}', otherDependencies)
    files['pom.xml'] = finalSource
    return files
end

function generateEntities()
    local models = project.Models
    local files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${modelName}', ModelName)
        local fieldCode = ''
        for k = 1, #models[i].Fields do
            fieldCode = fieldCode .. 'private String ' .. models[i].Fields[k].Name .. ';\n'
        end
        finalSource = finalSource.gsub(finalSource, '${fields}', go_add_indent(fieldCode, 4))
        files[ModelName .. '.java'] = finalSource
    end
    return files
end

function generateMappers()
    local models = project.Models
    local files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'Mapper.java'] = finalSource
    end
    return files
end

function generateMapperXmlFiles()
    local models = project.Models
    local files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        finalSource = string.gsub(finalSource, '${tableName}', models[i].TablePrefix .. modelName)

        -- Fill in result map fields
        local resultMapFieldsCode = ''
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]
            if (field.Primary)
            then
                resultMapFieldsCode = resultMapFieldsCode .. '<id column="' .. field.Name .. '" property="' .. field.Name .. '" jdbcType="VARCHAR"/>\n'
            else
                resultMapFieldsCode = resultMapFieldsCode .. '<result column="' .. field.Name .. '" property="' .. field.Name .. '" jdbcType="VARCHAR"/>\n'
            end
        end
        resultMapFieldsCode = resultMapFieldsCode .. '<result column="created_time" property="createdTime" jdbcType="TIMESTAMP"/>\n'
        resultMapFieldsCode = resultMapFieldsCode .. '<result column="updated_time" property="updatedTime" jdbcType="TIMESTAMP"/>'
        finalSource = finalSource.gsub(finalSource, '${resultMapFields}', go_add_indent(resultMapFieldsCode, 8))

        -- Fill in query params and MyBatis params
        local queryParamsCode = ''
        local insertParamsCode = ''
        local mybatisParamsCode = ''
        local isFirstInsertField = true
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]
            if k > 1 then
                queryParamsCode = queryParamsCode .. ', '
            end

            queryParamsCode = queryParamsCode .. '`' .. field.Name .. '`'
            if field.Primary ~= true then
                if isFirstInsertField == true then
                    isFirstInsertField = false
                else
                    insertParamsCode = insertParamsCode .. ', '
                    mybatisParamsCode = mybatisParamsCode .. ', '
                end
                insertParamsCode = insertParamsCode .. '`' .. field.Name .. '`'
                mybatisParamsCode = mybatisParamsCode .. '#{' .. field.Name .. '}'
            end
        end
        queryParamsCode = queryParamsCode .. ', `created_time`, `updated_time`'
        finalSource = finalSource.gsub(finalSource, '${queryParams}', queryParamsCode)
        finalSource = finalSource.gsub(finalSource, '${insertParams}', insertParamsCode)
        finalSource = finalSource.gsub(finalSource, '${mybatisParams}', mybatisParamsCode)

        -- Fill in update fields
        local updateFieldsCode = ''
        local isFirstField = true
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]
            if (field.Primary == false) then
                if isFirstField then
                    isFirstField = false
                else
                    updateFieldsCode = updateFieldsCode .. ', '
                end
                updateFieldsCode = updateFieldsCode .. field.Name .. ' = #{' .. field.Name .. '}'
            end
        end
        finalSource = finalSource.gsub(finalSource, '${updateFields}', updateFieldsCode)

        files[ModelName .. 'Mapper.xml'] = finalSource
    end
    return files
end

function generateServices()
    local models = project.Models
    local files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'Service.java'] = finalSource
    end
    return files
end

function generateServiceImpls()
    local models = project.Models
    local files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'ServiceImpl.java'] = finalSource
    end
    return files
end

function generateControllers()
    local models = project.Models
    local files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'Controller.java'] = finalSource
    end
    return files
end

function generateSqlStatements()
    local models = project.Models
    local finalSource = ''
    local bridgeTables = {}
    for i = 1, #models do
        local modelName = models[i].Name
        finalSource = finalSource .. '-- ' .. models[i].TablePrefix .. modelName .. '\n'
        finalSource = finalSource .. 'DROP TABLE IF EXISTS `' .. models[i].TablePrefix .. modelName .. '`;\n'
        finalSource = finalSource .. 'CREATE TABLE IF NOT EXISTS `' .. models[i].TablePrefix .. modelName .. '` (\n'
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]

            -- Fill in field name
            finalSource = finalSource .. '    `' .. field.Name .. '` '

            -- Fill in field type
            local type = field.DbType
            if type == 'VARCHAR' then
                local length = 255
                if field.Length > 0 then length = field.Length end
                type = type .. '(' .. length .. ')'
            end
            finalSource = finalSource .. type

            -- Fill in primary key / null attributes
            if field.Primary then
                finalSource = finalSource .. ' PRIMARY KEY NOT NULL'
                if field.AutoIncrement then
                    finalSource = finalSource .. ' AUTO_INCREMENT'
                end
            elseif field.NotNull then
                finalSource = finalSource .. ' NOT NULL'
            end
            finalSource = finalSource .. ',\n'
        end
        finalSource = finalSource .. '    `created_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n'
        finalSource = finalSource .. '    `updated_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP\n'
        finalSource = finalSource .. ');\n\n'

        if models[i].Mappings ~= nil then
            for k = 1, #models[i].Mappings do
                local mapping = models[i].Mappings[k]
                if mapping.Type == 'many2many' then
                    local tableName = models[i].TablePrefix .. modelName .. '_' .. mapping.Model
                    finalSource = finalSource .. '-- ' .. tableName .. '\n' ..
                            'DROP TABLE IF EXISTS `' .. tableName .. '`;\n' ..
                            'CREATE TABLE IF NOT EXISTS `' .. tableName .. '` (\n' ..
                            '    `' .. modelName .. '_id` BIGINT NOT NULL,\n' ..
                            '    `' .. mapping.Model .. '_id` BIGINT NOT NULL,\n' ..
                            '    `created_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n' ..
                            '    PRIMARY KEY (' .. modelName .. '_id, ' .. mapping.Model .. '_id)\n' ..
                            ');\n\n'
                end
            end
        end
    end
    local files = {}
    files[project.Name .. '.sql'] = finalSource
    return files
end

function generateCrossOriginConfig()
    models = project.Models
    local files = {}
    local finalSource = source
    for i = 1, #template.Properties do
        if template.Properties[i].Name == 'cross-origin.allowed-headers' then
            local value = template.Properties[i].Value
            if value == '*' then
                finalSource = string.gsub(finalSource, '${addAllowedHeaders}', 'corsConfiguration.addAllowedHeader("*");')
            else
                -- TODO: split function should be used here
                local headers = string.sub(',', 1)
                local tmp = ''
                for k = 1, #headers do
                    tmp = tmp .. '\n    corsConfiguration.addAllowedHeader("' .. headers[k] .. '");'
                end
                finalSource = string.gsub(finalSource, '${addAllowedHeaders}', tmp)
            end
        end
    end
    -- Remove redundant params
    finalSource = string.gsub(finalSource, '${addAllowedHeaders}', '')
    files['CrossOriginConfig.java'] = finalSource
    return files
end

function generateServiceTests()
    local models = project.Models
    local files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'ServiceTest.java'] = finalSource
    end
    return files
end

function generatePostmanCollection()
    local finalSource = go_read_template_file(template.Name, 'content/PostmanCollectionOuter.json')
    local models = project.Models
    local itemSource = ''
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        itemSource = itemSource .. '{"name": "' .. ModelName .. '", "item": [${subItems}]}' .. (i ~= #models and ',' or '')
        local subItemSource = ''
        local requestUrl = 'http://localhost:' .. properties['server.port'] .. '/api/' .. properties['project.artifactId'] .. '/' .. modelName
        local paths = '"api", "' .. properties['project.artifactId'] .. '", "' .. modelName .. '"'
        local paginationParams = '{ "key": "pageSize", "value": "5" }, { "key": "pageNo", "value": "1" }'
        local requestBody = '{"id": 1, "name": "Tom"}'
        local requestTables = {
            { name = 'Query ' .. ModelName, method = 'GET', query = paginationParams, body = '', url = requestUrl, path = paths },
            { name = 'Create ' .. ModelName, method = 'POST', query = '', body = requestBody, url = requestUrl, path = paths },
            { name = 'Update ' .. ModelName, method = 'PUT', query = '', body = requestBody, url = requestUrl, path = paths },
            { name = 'Delete ' .. ModelName, method = 'DELETE', query = '', body = '', url = requestUrl .. '/1', path = paths .. ', "1"' }
        }

        for k = 1, #requestTables do
            local table = requestTables[k]
            subItemSource = subItemSource .. source .. ','
            subItemSource = string.gsub(subItemSource, '${requestName}', table['name'])
            subItemSource = string.gsub(subItemSource, '${requestMethod}', table['method'])
            subItemSource = string.gsub(subItemSource, '${query}', table['query'])
            subItemSource = string.gsub(subItemSource, '${requestBody}', table['body'])
            subItemSource = string.gsub(subItemSource, '${requestUrl}', table['url'])
            subItemSource = string.gsub(subItemSource, '${paths}', table['path'])
        end

        subItemSource = string.gsub(subItemSource, '${requestHost}', 'localhost')
        subItemSource = string.gsub(subItemSource, '${port}', properties['server.port'])
        itemSource = string.gsub(itemSource, '${subItems}', subItemSource)
    end

    finalSource = string.gsub(finalSource, '${items}', itemSource)
    local files = {}
    files[project.Name .. '.postman_collection.json'] = go_json_format(finalSource)
    return files
end

function generateProperties()
    local files = {}

    for i = 1, #(project.Deployment.Env) do
        local env = project.Deployment.Env[i]
        local finalSource = ''

        -- Add MySQL properties
        if env.Middleware.Mysql ~= nil and #(env.Middleware.Mysql) > 0 then
            local mysql = env.Middleware.Mysql[1]
            local mysqlProperties = go_read_template_file(template.Name, 'content/properties/mysql.properties', mysql)
            mysqlProperties = string.gsub(mysqlProperties, '${mysql.EncryptedPassword}', go_jasypt_encrypt(mysql.Password))
            finalSource = finalSource .. mysqlProperties .. '\n\n'
        end

        -- Add Redis properties
        if env.Middleware.Redis ~= nil and #(env.Middleware.Redis) > 0 then
            local redis = env.Middleware.Redis[1]
            local redisProperties = go_read_template_file(template.Name, 'content/properties/redis.properties', redis)
            redisProperties = string.gsub(redisProperties, '${redis.EncryptedPassword}', go_jasypt_encrypt(redis.Password))
            finalSource = finalSource .. redisProperties .. '\n\n'
        end

        -- Add Passport SDK properties
        if plugins['vancone-passport-sdk'] == true then
            local baseUrl = (env.Profile == 'pro' or env.Profile == 'prod') and 'https://passport.vancone.com' or 'http://passport.beta.vancone.com'
            local passportSdkProperties = go_read_template_file(template.Name, 'content/properties/vancone-passport-sdk.properties')
            passportSdkProperties = string.gsub(passportSdkProperties, '${passport.baseUrl}', baseUrl)
            passportSdkProperties = string.gsub(passportSdkProperties, '${passport.accessKeyId}', go_jasypt_encrypt(properties['vancone.passport.service-account.access-key-id']))
            passportSdkProperties = string.gsub(passportSdkProperties, '${passport.secretAccessKey}', go_jasypt_encrypt(properties['vancone.passport.service-account.secret-access-key']))
            finalSource = finalSource .. passportSdkProperties .. '\n\n'
        end

        files['application-' .. env.Profile .. '.properties'] = finalSource
    end

    return files
end