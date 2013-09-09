#
_ajax_json = (url,data,success) ->
  $.ajax({
    url, data, traditional: true, success, dataType: 'json',
  })

window.rhs_templates =
  tophit:
    template: """
      <div class="solr_tophit">
      </div>
    """
    postproc: (el,data) ->
      render_canvas = (canvas,location,text,colour) ->
        ctx = canvas.getContext('2d')
        line = (ctx,x,y,w,h) ->
          ctx.beginPath()
          ctx.moveTo(x+0.5,y+0.5)
          ctx.lineTo(x+w+0.5,y+h+0.5)
          ctx.closePath()
          ctx.stroke()
        arrow = ((ctx,x,y,s,d) -> line(ctx,x,y,d*s,-s) ; line(ctx,x,y,d*s,s))
        ctx.lineWidth = 1
        ctx.strokeStyle = '#cccccc'
        [chr,start,end,strand] = location.split /[:-]/
        start = parseInt(start)
        end = parseInt(end)
        len = end - start + 1
        size = parseInt('1'+new Array(len.toString().length+1).join('0'))
        sstr = size.toString().replace(/000$/,'k').replace(/000k$/,'M') + 'b'
        img_start = (end+start-size)/2
        bp_per_px = size / canvas.width
        h = canvas.height
        step = size/13/bp_per_px
        step_start = (Math.floor(img_start/step)*step - img_start)/bp_per_px
        for i in [0..13]
          offset = step_start + step * i
          line(ctx,offset,0,0,h)
          unless i%2
            ctx.fillRect(offset,0,step,3)
        ctx.fillStyle = colour
        ctx.fillRect((start-img_start)/bp_per_px,30,len/bp_per_px,6)
        ctx.font = '10px sans-serif'
        text = ( if parseInt(strand) > 0 then text+" >" else "< "+text )
        ctx.fillText(text,(start-img_start)/bp_per_px,25)
        ctx.fillText(location,step_start+step*4+4,45)
        ctx.strokeStyle = 'black'
        ctx.fillStyle = 'black'
        ctx.lineWidth = 1
        line(ctx,0,0,canvas.width,0)
        line(ctx,0,3,canvas.width,0)
        line(ctx,step_start+step*2,10,step*4,0)
        line(ctx,step_start+step*8,10,step*4,0)
        arrow(ctx,step_start+step*2,10,4,1)
        arrow(ctx,step_start+step*12,10,4,-1)
        ctx.fillText(sstr,step_start+step*6,15)
      
      $(document).on 'first_result', (e,query,data,state) ->
        if state.page() != 1 then return
        tophit = data.rows?[0]
        if not tophit? then return
        el.empty()
        if tophit.feature_type == 'Gene'
          extra = {}
          desc = tophit.description.replace /\[(.*?)\:(.*?)\]/g, (g0,g1,g2) ->
            extra[g1.trim().toLowerCase()] = g2.trim()
            ''
          if extra.source
            extra.source = extra.source.replace(/;/g,'; ')
          latin = $.solr_config('spnames.%',tophit.species)
          _ajax_json "/Multi/Ajax/extra", {
            queries: JSON.stringify({
              queries: [
                { ft: 'Gene', id: tophit.id, species: latin, req: ['biotype','bt_colour'], db: tophit.database_type }
              ]})
          }, (data) =>
            [biotype,bt_colour] = data.result
            templates = $(document).data("templates")
            el.append(templates.generate('sctophit',{
              q: query.q, url: tophit.url, name: tophit.name, ft: "Gene"
              species: tophit.species
              source: extra.source, latin: latin
              location: tophit.location
              render_canvas
              biotype, bt_colour, description: desc
            }))
            $('html').trigger('wrap')
  
  sctophit:
    template: """ 
      <div class="sctophit scside">
        <div class="scth_play">&#x21AA;</div>
        <h1>Best match</h1>
        <div class="scth_left">
          <div class="scth_type"></div>
          <div class="scth_name maybe_wrap"></div>
          <div class="scth_source"></div>
        </div>
        <div class="scth_right">
          <div class="scth_top">
            <div class="scth_species">
              <img alt="" title=""/>
            </div>
            <div class="scth_canvas">
              <div class="scth_canvas_holder">
                <canvas width="221" height="58">
                  Click for full details
                </canvas>
              </div>
            </div>
          </div>
          <div class="scth_biotype"></div>
          <div class="scth_desc"></div>
        </div>
      </div>
    """ 
    directives:
      '.scth_name': 'name'
      '.scth_type': 'title'
      '.scth_source': 'source'
      '.scth_species img@src': 'img'
      '.scth_species img@alt': 'species'
      '.scth_species img@title': 'species'
      '.scth_biotype': 'biotype'
      '.scth_desc': 'description'
    decorate:
      '.scth_canvas canvas': (el,data) ->
        if el.length == 0 or not el[0]? or not el[0].getContext? then return
        ctx = el[0].getContext('2d')
        line = (ctx,x,y,w,h) ->
          ctx.beginPath()
          ctx.moveTo(x+0.5,y+0.5)
          ctx.lineTo(x+w+0.5,y+h+0.5)
          ctx.closePath()
          ctx.stroke()
        arrow = ((ctx,x,y,s,d) -> line(ctx,x,y,d*s,-s) ; line(ctx,x,y,d*s,s))
        ctx.lineWidth = 1
        ctx.strokeStyle = '#cccccc'
        [chr,start,end,strand] = data.location.split /[:-]/
        start = parseInt(start)
        end = parseInt(end)
        len = end - start + 1
        size = parseInt('1'+new Array(len.toString().length+1).join('0'))
        sstr = size.toString().replace(/000$/,'k').replace(/000k$/,'M') + 'b'
        img_start = (end+start-size)/2
        bp_per_px = size / el[0].width
        h = el[0].height
        step = size/13/bp_per_px
        step_start = (Math.floor(img_start/step)*step - img_start)/bp_per_px
        for i in [0..13]
          offset = step_start + step * i
          line(ctx,offset,0,0,h)
          unless i%2
            ctx.fillRect(offset,0,step,3)
        ctx.fillStyle = data.bt_colour
        ctx.fillRect((start-img_start)/bp_per_px,30,len/bp_per_px,6)
        ctx.font = '10px sans-serif'
        text = ( if parseInt(strand) > 0 then data.name+" >" else "< "+data.name )
        ctx.fillText(text,(start-img_start)/bp_per_px,25)
        ctx.fillText(data.location,step_start+step*4+4,45)
        ctx.strokeStyle = 'black'
        ctx.fillStyle = 'black'
        ctx.lineWidth = 1
        line(ctx,0,0,el[0].width,0)
        line(ctx,0,3,el[0].width,0)
        line(ctx,step_start+step*2,10,step*4,0)
        line(ctx,step_start+step*8,10,step*4,0)
        arrow(ctx,step_start+step*2,10,4,1)
        arrow(ctx,step_start+step*12,10,4,-1)
        ctx.fillText(sstr,step_start+step*6,15)
      
      '.sctophit': (el,data) ->
        el.on 'click', (e) =>
          window.location.href = data.url

    preproc: (spec,data) ->
      data.img = "/i/species/64/#{data.latin}.png"
      data.biotype = data.biotype.replace(/_/g,' ')
      data.biotype = "#{data.biotype} #{data.ft}"
      data.biotype = data.biotype.charAt(0).toUpperCase() + data.biotype.substring(1).toLowerCase()
      data.title = "#{data.species} #{data.ft}"
      [spec,data]

  'topgene':
    template: """
      <div class='solr_topgene'>
      </div>
    """
    postproc: (el,data) ->
      $(document).on 'first_result', (e,query,data,state) ->
        if state.page() != 1 then return
        el.empty()
        params = {
          q: 'name:"'+query.q+'"'
          rows: 200
          fq: "feature_type:Gene AND database_type:core"
          'facet.field': "species"
          'facet.mincount': 1
          facet: true 
        }    
        _ajax_json "/Multi/Ajax/search", params, (data) =>
          sp_glinks = {} 
          docs = data.result?.response?.docs
          if docs?
            for d in docs 
              if d.ref_boost >= 10 and d.species
                url = d.domain_url
                if url?.charAt(0) != '/' then url = "/" + url
                sp_glinks[d.species] = "/"+d.domain_url
          if (k for k,v of sp_glinks).length > 0
            rows = ( k for k,v of sp_glinks )
            favord = []
            for s,i in $.solr_config('user.favs.species')
              favord[s] = i
            rows = rows.sort (a,b) -> 
              if favord[a]? and ((not favord[b]?) or favord[a] < favord[b])
                return -1
              if favord[b]? then return 1
              return a.localeCompare(b)
            templates = $(document).data("templates")
            el.append(templates.generate('sctopgene',{ urls: sp_glinks, rows, q: query.q }))

  sctopgene:
    template: """
      <div class="sctopgene scside">
        <h1>Direct link to genes named "<span></span>"</h1>
        <ul>
          <li>
            <a href="#">
              <img src="" alt="" title=""/>
            </a>
          </li>
        </ul>
        <div class="sctg_dots">more ...</div>
      </div>
    """
    directives:
      'li':
        'sp<-entries':
          'img@src': 'sp.url'
          'img@alt': 'sp.name'
          'img@title': 'sp.name'
          'a@href': 'sp.link'
      'h1 span': 'q'
    decorate:
      '.sctg_dots': (el,data) ->
        if data.entries.length <= 8 # num on first row
          el.hide()
      '.sctopgene': (el,data) ->
        if data.entries.length <= 8 # num on first row
          el.css('max-height','inherit')
    preproc: (spec,data) ->
      entries = []
      for n in data.rows
        latin = $.solr_config("spnames.%",n)
        if latin
          entries.push {
            url: "/i/species/48/#{latin}.png" 
            link: data.urls[n]
            name: n
          }
      data.entries = entries
      [spec,data]
    
  noresultssuggest:
    template: """
      <div class="scsuggest">
        <div class="scsug-fold"><a href='#'>Did you mean... <small>&#x25BC;</small></a></div>
        <div class="scsug-main">
          <h1>Suggestions</h1>
          <div class="cloud">
            <a href="#">word</a>
          </div>
        </div>
      </div>
    """
    directives:
      '.cloud a':
        'word<-suggestions':
          '.': 'word.word'
          '@href': (e) -> "#" + e.item.word
          '@style': (e) ->
            w = e.item.weight
            col = [3*16,6*16,11*16] # #36b
            col[i] = Math.floor(w*c + 255*(1-w)) for c,i in col
            out = "background: rgb(" + col.join(",") + "); color: rgb("
            s = Math.floor((1-w)*64)
            f = Math.floor(w*12)+10
            out += [s,s,s].join(",")+"); font-size: #{f}px;"
            out
    decorate:
      '.cloud a': (els,data) ->
        els.on 'click', (e) =>
          el = $(e.currentTarget)
          href = el.attr('href')
          href = href.substring(href.indexOf('#')) # IE7, :-(
          state = { page: 1 }
          for f in $.solr_config('static.ui.facets')
            state["facet_"+f.key] = ''
          state.q = href.substring(1)
          $(document).trigger('update_state',[state])
          false
      '.scsug-main': (els,data) ->
        if data.someresults and data.mainflow
          els.addClass('scnbox-hidden')
        els.addClass(if data.mainflow then 'scnarrow' else 'scside')
      '.scsug-fold': (els,data) ->
        if not data.someresults or not data.mainflow then els.hide()
      '.scsug-fold a': (els,data) ->
        els.on 'click', () =>
          els.closest('.scsuggest').find('.scsug-main')
            .toggleClass('scnbox-hidden')
          false

  noresults:
    template: """
      <div></div>
    """
    postproc: (el,data) ->
      $(document).on 'first_result', (e,query,rdata,state) ->
        _ajax_json "/Multi/Ajax/search", {
          'spellcheck.q': query.q.toLowerCase()
          spellcheck: true
          'spellcheck.count': 50
          'spellcheck.onlyMorePopular': false
        }, (data) =>
          suggestions = []
          words = data.result?.spellcheck?.suggestions?[1]?.suggestion
          unless words?.length then return
          for word,i in words
            w = Math.sqrt(((words.length-i)/words.length))
            if rdata.num then w = w/2
            suggestions.push {
              word
              weight: w*w
            }
          mainflow = ( rdata.num == 0 or
              not $('.sidecar_holder').is(':visible') or
              not $('.sidecar_holder').length )
          dest = null
          el.empty()
          el.each () ->
            if mainflow and $(@).closest('.noresults_main').length
              dest = $(@)
            else if (not mainflow) and $(@).closest('.noresults_side').length
              dest = $(@)
          templates = $(document).data("templates")
          dest.append(templates.generate('noresultssuggest',{
            suggestions,
            someresults: ( rdata.num != 0 )
            mainflow
          }))

  narrowresults:
    template: """
      <div></div>
    """
    postproc: (el,data) ->
      $(document).on 'first_result', (e,query,rdata,state) ->
        el.empty()
        if rdata.num != 0 then return
        all_facets = (f.key for f in $.solr_config('static.ui.facets'))
        _ajax_json "/Multi/Ajax/search", {
            q: query.q
            rows: 1
            'facet.field': all_facets
            'facet.mincount': 1
            facet: true
          }, (data) =>
            cur_values = []
            othervalues = [] 
            for f in all_facets
              if query.facets[f] then cur_values.push([f,query.facets[f]])
              if data.result?.facet_counts?.facet_fields?[f]?
                entries = 0
                total = 0
                for e,i in data.result?.facet_counts?.facet_fields?[f]
                  if i%2
                    entries += 1
                    total += e
                if entries > 0
                  name = $.solr_config('static.ui.facets.key=.text.plural',f)
                  othervalues.push({ entries, total, name, facet: f })
            yoursearch = (k[1] for k in cur_values).join(" ")
            wholesite = (cur_values.length == 0)
            templates = $(document).data('templates')
            el.append(templates.generate('noresultsnarrow',{
              q: query.q, yoursearch, othervalues, wholesite
              unrestrict_facets: () =>
                state = { page: 1 }
                for f in all_facets
                  state["facet_"+f] = ''
                $(document).trigger('update_state',[state])
                false
            }))


  noresultsnarrow:
    template: """
      <div class="scnarrow">
        <h1>No results for <em>thing</em> '<i class='search'>search</i>'</h1>
        <ul>
          <li class="wide"><div>
            You were searching the whole site, but still nothing was found.
          </div></li>
          <li class="narrow"><div>
            You were only searching <em>thing</em>.
          </div></li>
          <li class="narrow_any"><div>
            And there are <i class="count">42</i> results in
            <i class="all">all</i> on the whole site.
            <a href="#">Search full site</a>.
          </div></li>
          <li class='narrow_none'><div>
            But there are no results in
            any category on the whole site, anyway.
          </div></li>
          <li><div class="roll_hidden">
            <a href="#">More help on searching ...</a>
            <div class="roll_hidden_text">
            </div>
          </div></li>
        </ul>
      </div>
    """
    directives:
      'em': 'yoursearch'
      '.roll_hidden_text': 'noresults_help'
      '.search': 'q'
      '.narrow_any':
        'x<-narrow_n':
          '.all': 'all'
          '.count': 'total'
      '.narrow_none': 'y<-narrow_none': {}
      '.wide': 'w<-wide': {}
      '.narrow': 'z<-narrow':
        'em': 'yoursearch'
    decorate:
      '.narrow_any a': (els,data) =>
        els.click (e) =>
          data.unrestrict_facets()
          false
      '.roll_hidden': (els,data) ->
        els.children('div').hide()
        els.children('a').on 'click', (e) =>
          els.children('div').toggle()
          false
    preproc: (spec,data) ->
      list = []
      if data.wholesite
        data.wide = [true]
      else
        data.narrow = [true]
        for ov in data.othervalues
          list.push(ov.entries+" "+ov.name)
          data.total = ov.total
        if data.othervalues.length == 0
          data.narrow_none = [true]
        else
          data.all = list.join(", ")
          data.narrow_n = [true]
      data.noresults_help = $.solr_config('static.ui.noresults_help')
      [spec,data]
